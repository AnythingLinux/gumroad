# frozen_string_literal: true

require "test_helper"

class InvoicePresenter::SupplierInfoTest < ActiveSupport::TestCase
  setup do
    @purchase = purchases(:invoice_seller_purchase)
    @sales_tax_info = purchase_sales_tax_infos(:invoice_seller_purchase_sales_tax_info)
  end

  def presenter(chargeable = @purchase)
    InvoicePresenter::SupplierInfo.new(chargeable)
  end

  test "#heading returns Supplier" do
    assert_equal "Supplier", presenter.heading
  end

  test "#attributes returns Gumroad attributes when not supplied by the seller" do
    @purchase.update_columns(country: nil, ip_country: nil)
    assert_equal(
      [
        { label: nil, value: "Gumroad, Inc." },
        {
          label: "Office address",
          value: "#{GumroadAddress::STREET}\n#{GumroadAddress::CITY}, #{GumroadAddress::STATE} #{GumroadAddress::ZIP_PLUS_FOUR}\n#{GumroadAddress::COUNTRY.common_name}"
        },
        { label: "Email", value: ApplicationMailer::NOREPLY_EMAIL },
        { label: "Web", value: ROOT_DOMAIN },
        { label: nil, value: "Products supplied by Gumroad." }
      ],
      presenter.attributes
    )
  end

  # -- gumroad_tax_attributes branches via Purchase#country_or_ip_country --

  test "gumroad_tax_attributes is nil when country is outside special jurisdictions" do
    @purchase.update_columns(country: "United States", ip_country: nil)
    assert_nil presenter.send(:gumroad_tax_attributes)
  end

  test "gumroad_tax_attributes returns VAT info for an EU country" do
    @purchase.update_columns(country: "Italy", ip_country: nil)
    assert_equal(
      [{ label: "VAT Registration Number", value: GUMROAD_VAT_REGISTRATION_NUMBER }],
      presenter.send(:gumroad_tax_attributes)
    )
  end

  test "gumroad_tax_attributes returns ABN info for Australia" do
    @purchase.update_columns(country: "Australia", ip_country: nil)
    assert_equal(
      [{ label: "Australian Business Number", value: GUMROAD_AUSTRALIAN_BUSINESS_NUMBER }],
      presenter.send(:gumroad_tax_attributes)
    )
  end

  test "gumroad_tax_attributes returns GST info for Canada" do
    @purchase.update_columns(country: "Canada", ip_country: nil)
    @sales_tax_info.update!(country_code: Compliance::Countries::CAN.alpha2, state_code: nil)
    assert_equal(
      [{ label: "Canada GST Registration Number", value: GUMROAD_CANADA_GST_REGISTRATION_NUMBER }],
      presenter.send(:gumroad_tax_attributes)
    )
  end

  test "gumroad_tax_attributes returns GST + QST info for Quebec" do
    @purchase.update_columns(country: "Canada", ip_country: nil)
    @sales_tax_info.update!(country_code: Compliance::Countries::CAN.alpha2, state_code: "QC")
    assert_equal(
      [
        { label: "Canada GST Registration Number", value: GUMROAD_CANADA_GST_REGISTRATION_NUMBER },
        { label: "QST Registration Number", value: GUMROAD_QST_REGISTRATION_NUMBER }
      ],
      presenter.send(:gumroad_tax_attributes)
    )
  end

  test "gumroad_tax_attributes returns GST + BC PST info for British Columbia" do
    @purchase.update_columns(country: "Canada", ip_country: nil)
    @sales_tax_info.update!(country_code: Compliance::Countries::CAN.alpha2, state_code: "BC")
    assert_equal(
      [
        { label: "Canada GST Registration Number", value: GUMROAD_CANADA_GST_REGISTRATION_NUMBER },
        { label: "BC PST Registration Number", value: GUMROAD_CANADA_BC_PST }
      ],
      presenter.send(:gumroad_tax_attributes)
    )
  end

  test "gumroad_tax_attributes returns GST + SK PST info for Saskatchewan" do
    @purchase.update_columns(country: "Canada", ip_country: nil)
    @sales_tax_info.update!(country_code: Compliance::Countries::CAN.alpha2, state_code: "SK")
    assert_equal(
      [
        { label: "Canada GST Registration Number", value: GUMROAD_CANADA_GST_REGISTRATION_NUMBER },
        { label: "SK PST Registration Number", value: GUMROAD_CANADA_SK_PST }
      ],
      presenter.send(:gumroad_tax_attributes)
    )
  end

  test "gumroad_tax_attributes returns GST + MB RST info for Manitoba" do
    @purchase.update_columns(country: "Canada", ip_country: nil)
    @sales_tax_info.update!(country_code: Compliance::Countries::CAN.alpha2, state_code: "MB")
    assert_equal(
      [
        { label: "Canada GST Registration Number", value: GUMROAD_CANADA_GST_REGISTRATION_NUMBER },
        { label: "MB RST Registration Number", value: GUMROAD_CANADA_MB_RST }
      ],
      presenter.send(:gumroad_tax_attributes)
    )
  end

  test "gumroad_tax_attributes uses ip_country when country is blank (EU)" do
    @purchase.update_columns(country: nil, ip_country: "Italy")
    assert_equal(
      [{ label: "VAT Registration Number", value: GUMROAD_VAT_REGISTRATION_NUMBER }],
      presenter.send(:gumroad_tax_attributes)
    )
  end

  test "gumroad_tax_attributes is nil for a non-collecting country via ip_country" do
    @purchase.update_columns(country: nil, ip_country: "Iceland")
    assert_nil presenter.send(:gumroad_tax_attributes)
  end

  test "gumroad_tax_attributes returns UK VAT info for United Kingdom" do
    @purchase.update_columns(country: "United Kingdom", ip_country: nil)
    assert_equal(
      [{ label: "UK VAT Registration", value: GUMROAD_UK_VAT_REGISTRATION }],
      presenter.send(:gumroad_tax_attributes)
    )
  end

  test "gumroad_tax_attributes returns GSTIN for India via ip_country" do
    @purchase.update_columns(country: nil, ip_country: "India")
    assert_equal(
      [{ label: "GSTIN", value: GUMROAD_INDIA_GSTIN }],
      presenter.send(:gumroad_tax_attributes)
    )
  end

  test "gumroad_tax_attributes returns JCT for Japan via ip_country" do
    @purchase.update_columns(country: nil, ip_country: "Japan")
    assert_equal(
      [{ label: "JCT Registration Number", value: GUMROAD_JAPAN_JCT }],
      presenter.send(:gumroad_tax_attributes)
    )
  end

  test "gumroad_tax_attributes returns NZ GST for New Zealand via ip_country" do
    @purchase.update_columns(country: nil, ip_country: "New Zealand")
    assert_equal(
      [{ label: "New Zealand GST", value: GUMROAD_NEW_ZEALAND_GST }],
      presenter.send(:gumroad_tax_attributes)
    )
  end

  test "gumroad_tax_attributes returns FIRS TIN for Nigeria via ip_country" do
    @purchase.update_columns(country: nil, ip_country: "Nigeria")
    assert_equal(
      [{ label: "FIRS TIN", value: GUMROAD_NIGERIA_TIN }],
      presenter.send(:gumroad_tax_attributes)
    )
  end

  test "gumroad_tax_attributes returns Singapore GST via ip_country" do
    @purchase.update_columns(country: nil, ip_country: "Singapore")
    assert_equal(
      [{ label: "Singapore GST", value: GUMROAD_SINGAPORE_GST }],
      presenter.send(:gumroad_tax_attributes)
    )
  end

  test "gumroad_tax_attributes returns South Korea VAT via ip_country" do
    @purchase.update_columns(country: nil, ip_country: "South Korea")
    assert_equal(
      [{ label: "South Korea VAT", value: GUMROAD_SOUTH_KOREA_VAT }],
      presenter.send(:gumroad_tax_attributes)
    )
  end

  test "gumroad_tax_attributes returns Switzerland VAT via ip_country" do
    @purchase.update_columns(country: nil, ip_country: "Switzerland")
    assert_equal(
      [{ label: "Switzerland VAT", value: GUMROAD_SWITZERLAND_VAT }],
      presenter.send(:gumroad_tax_attributes)
    )
  end

  test "gumroad_tax_attributes returns Thailand VAT via ip_country" do
    @purchase.update_columns(country: nil, ip_country: "Thailand")
    assert_equal(
      [{ label: "Thailand VAT", value: GUMROAD_THAILAND_VAT }],
      presenter.send(:gumroad_tax_attributes)
    )
  end

  test "gumroad_tax_attributes returns Norway MVA via country" do
    @purchase.update_columns(country: "Norway", ip_country: nil)
    assert_equal(
      [{ label: "Norway VAT Registration", value: GUMROAD_NORWAY_VAT_REGISTRATION }],
      presenter.send(:gumroad_tax_attributes)
    )
  end
end
