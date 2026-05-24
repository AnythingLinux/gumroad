# frozen_string_literal: true

require "test_helper"

class InvoicePresenter::OrderInfoTest < ActiveSupport::TestCase
  setup do
    @purchase = purchases(:invoice_seller_purchase)
    @sales_tax_info = purchase_sales_tax_infos(:invoice_seller_purchase_sales_tax_info)
    @address_fields = {
      full_name: "Customer Name",
      street_address: "1234 Main St",
      city: "City",
      state: "State",
      zip_code: "12345",
      country: "United States"
    }
    @additional_notes = "Here is the note!\nIt has multiple lines."
    @business_vat_id = "VAT12345"
  end

  def presenter(chargeable: @purchase, address_fields: @address_fields, additional_notes: @additional_notes, business_vat_id: @business_vat_id, **opts)
    InvoicePresenter::OrderInfo.new(
      chargeable,
      address_fields:,
      additional_notes:,
      business_vat_id:,
      **opts
    )
  end

  # -- heading --

  test "#heading returns Invoice when not direct to Australian customer" do
    assert_equal "Invoice", presenter.heading
  end

  test "#heading returns Receipt when direct to Australian customer" do
    @purchase.link.update_column(:flags, @purchase.link.flags | 128) # is_physical
    @purchase.update_columns(country: "Australia")
    assert_equal "Receipt", presenter.heading
  end

  # -- pdf_attributes / structural slots --

  test "#pdf_attributes includes invoice date and order number" do
    @purchase.update_columns(created_at: Time.zone.parse("2023-01-01"))
    attrs = presenter.pdf_attributes
    assert_includes attrs, { label: "Date", value: "Jan 1, 2023" }
    assert_includes attrs, { label: "Order number", value: @purchase.external_id_numeric.to_s }
  end

  test "#pdf_attributes includes the address block when address_fields are present" do
    attrs = presenter.pdf_attributes
    assert_includes attrs, {
      label: "To",
      value: "Customer Name<br>1234 Main St<br>City, State, 12345<br>United States"
    }
  end

  test "#pdf_attributes inserts business_name in the To block after the full name" do
    attrs = presenter(business_name: "Acme Corp").pdf_attributes
    assert_includes attrs, {
      label: "To",
      value: "Customer Name<br>Acme Corp<br>1234 Main St<br>City, State, 12345<br>United States"
    }
  end

  test "#pdf_attributes omits a blank business_name from the To block" do
    attrs = presenter(business_name: "  ").pdf_attributes
    assert_includes attrs, {
      label: "To",
      value: "Customer Name<br>1234 Main St<br>City, State, 12345<br>United States"
    }
  end

  test "#pdf_attributes includes additional notes as a formatted block" do
    assert_includes presenter.pdf_attributes, {
      label: "Additional notes",
      value: "<p>Here is the note!\n<br />It has multiple lines.</p>"
    }
  end

  test "#pdf_attributes includes the customer email" do
    assert_includes presenter.pdf_attributes, { label: "Email", value: "customer@example.com" }
  end

  # -- business_vat_id_attribute branches --

  test "#pdf_attributes labels business_vat_id as VAT ID by default" do
    assert_includes presenter.pdf_attributes, { label: "VAT ID", value: "VAT12345" }
  end

  test "#pdf_attributes labels business_vat_id as ABN ID for Australia" do
    @sales_tax_info.update!(country_code: Compliance::Countries::AUS.alpha2)
    assert_includes presenter.pdf_attributes, { label: "ABN ID", value: "VAT12345" }
  end

  test "#pdf_attributes labels business_vat_id as GST ID for Singapore" do
    @sales_tax_info.update!(country_code: Compliance::Countries::SGP.alpha2)
    assert_includes presenter.pdf_attributes, { label: "GST ID", value: "VAT12345" }
  end

  test "#pdf_attributes labels business_vat_id as QST ID for Quebec, Canada" do
    @sales_tax_info.update!(country_code: Compliance::Countries::CAN.alpha2, state_code: "QC")
    assert_includes presenter.pdf_attributes, { label: "QST ID", value: "VAT12345" }
  end

  test "#pdf_attributes uses the submitted country label when business_vat_id_country_code is provided" do
    @sales_tax_info.update!(country_code: Compliance::Countries::AUS.alpha2)
    attrs = presenter(
      business_vat_id: "DE123456789",
      business_vat_id_country_code: "DE",
      show_reverse_charge_note: false
    ).pdf_attributes
    assert_includes attrs, { label: "VAT ID", value: "DE123456789" }
    refute attrs.any? { |a| a[:value].to_s.include?("Reverse Charge") }
  end

  # -- reverse-charge note branches --

  test "#pdf_attributes includes the reverse-charge VAT note for an EU sales-tax-info country" do
    assert_includes presenter.pdf_attributes, {
      label: nil,
      value: "Reverse Charge - You are required to account for the VAT"
    }
  end

  test "#pdf_attributes includes the reverse-charge GST note for Australia" do
    @sales_tax_info.update!(country_code: Compliance::Countries::AUS.alpha2)
    assert_includes presenter.pdf_attributes, {
      label: nil,
      value: "Reverse Charge - You are required to account for the GST"
    }
  end

  test "#pdf_attributes includes the reverse-charge QST note for Quebec, Canada" do
    @sales_tax_info.update!(country_code: Compliance::Countries::CAN.alpha2, state_code: "QC")
    assert_includes presenter.pdf_attributes, {
      label: nil,
      value: "Reverse Charge - You are required to account for the QST"
    }
  end

  # -- form_attributes --

  test "#form_attributes excludes invoice-only header blocks" do
    attrs = presenter(address_fields: { full_name: nil, street_address: nil, city: nil, state: nil, zip_code: nil, country: nil }, additional_notes: nil, business_vat_id: nil).form_attributes
    labels = attrs.map { |a| a[:label] }
    refute_includes labels, "Date"
    refute_includes labels, "Order number"
    refute_includes labels, "To"
    refute_includes labels, "Additional notes"
    assert_includes labels, "Email"
  end

  test "#form_attributes includes business_vat_id when stored on purchase_sales_tax_info" do
    @sales_tax_info.update!(business_vat_id: "FI98765")
    attrs = presenter(address_fields: { full_name: nil, street_address: nil, city: nil, state: nil, zip_code: nil, country: nil }, additional_notes: nil, business_vat_id: nil).form_attributes
    assert_includes attrs, { label: "VAT ID", value: "FI98765" }
    assert_includes attrs, { label: nil, value: "Reverse Charge - You are required to account for the VAT" }
  end
end
