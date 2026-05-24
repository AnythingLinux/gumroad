# frozen_string_literal: true

require "test_helper"
require "support/controller_seller_auth_helpers"

class Settings::BillingControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @seller = users(:named_seller)
    sign_in_as_seller(@seller)
    @request.headers["X-Inertia"] = "true"
  end

  teardown { restore_protect_against_forgery! }

  test "GET show returns success and renders Settings/Billing/Show" do
    get :show
    assert_response :success
    page = JSON.parse(@response.body)
    assert_equal "Settings/Billing/Show", page["component"]
    assert_kind_of Hash, page["props"]["countries"]
    assert_includes page["props"]["business_id_country_codes"], "DE"
    assert_equal true, page["props"]["billing_detail"]["auto_email_invoice_enabled"]
  end

  test "GET show pre-fills existing billing details" do
    BillingDetail.create!(
      purchaser: @seller,
      full_name: "Alice GmbH",
      business_name: "Acme",
      business_id: "DE123456789",
      street_address: "1 Unter den Linden",
      city: "Berlin",
      zip_code: "10115",
      country_code: "DE"
    )

    get :show
    page = JSON.parse(@response.body)
    assert_equal "Alice GmbH", page["props"]["billing_detail"]["full_name"]
    assert_equal "Acme", page["props"]["billing_detail"]["business_name"]
    assert_equal "DE123456789", page["props"]["billing_detail"]["business_id"]
    assert_equal "DE", page["props"]["billing_detail"]["country_code"]
  end

  test "PUT update creates BillingDetail when none exists" do
    valid = {
      billing_detail: {
        full_name: "Alice GmbH",
        business_name: "Acme",
        business_id: "DE123456789",
        street_address: "1 Unter den Linden",
        city: "Berlin",
        zip_code: "10115",
        country_code: "DE",
        additional_notes: "",
        auto_email_invoice_enabled: true,
      }
    }
    assert_difference -> { BillingDetail.count }, 1 do
      put :update, params: valid
    end
    assert_redirected_to settings_billing_path
    assert_equal "Your billing details have been saved.", flash[:notice]
    bd = @seller.reload.billing_detail
    assert_equal "Acme", bd.business_name
    assert_equal "DE", bd.country_code
  end

  test "PUT update updates existing BillingDetail instead of creating another" do
    existing = BillingDetail.create!(
      purchaser: @seller,
      full_name: "Old Name",
      street_address: "1 Unter den Linden",
      city: "Berlin",
      zip_code: "10115",
      country_code: "DE"
    )
    valid = {
      billing_detail: {
        full_name: "Alice GmbH",
        business_name: "Acme",
        business_id: "DE123456789",
        street_address: "1 Unter den Linden",
        city: "Berlin",
        zip_code: "10115",
        country_code: "DE",
        additional_notes: "",
        auto_email_invoice_enabled: true,
      }
    }
    assert_no_difference -> { BillingDetail.count } do
      put :update, params: valid
    end
    assert_equal "Alice GmbH", existing.reload.full_name
  end

  test "PUT update redirects without persisting when validation fails" do
    valid = {
      billing_detail: {
        full_name: "",
        country_code: "DE",
      }
    }
    assert_no_difference -> { BillingDetail.count } do
      put :update, params: valid
    end
    assert_redirected_to settings_billing_path
  end
end
