# frozen_string_literal: true

require "test_helper"
require "support/controller_seller_auth_helpers"

class Checkout::FormControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @seller = users(:named_seller)
    @admin = users(:admin_for_named_seller)
    sign_in_as_seller(@admin, @seller)
  end

  teardown { restore_protect_against_forgery! }

  test "GET show returns success and renders Checkout/Form/Show via inertia HTML payload" do
    get :show
    assert_response :success
    assert_includes @response.body, "data-page="
    match = @response.body.match(/data-page="([^"]*)"/)
    assert match, "Expected Inertia.js data-page attribute"
    page = JSON.parse(CGI.unescapeHTML(match[1]))
    assert_equal "Checkout/Form/Show", page["component"]
    assert page["props"].present?
  end

  test "PUT update updates the seller's checkout form" do
    refute @seller.display_offer_code_field
    put :update, params: {
      user: {
        display_offer_code_field: true,
        recommendation_type: User::RecommendationType::NO_RECOMMENDATIONS,
        tipping_enabled: true
      },
      custom_fields: [{ id: nil, type: "text", name: "Field", required: true, global: true }]
    }
    @seller.reload
    assert @seller.display_offer_code_field
    assert @seller.tipping_enabled?
    assert_equal User::RecommendationType::NO_RECOMMENDATIONS, @seller.recommendation_type
    assert_equal 1, @seller.custom_fields.count
    field = @seller.custom_fields.last
    assert_equal "Field", field.name
    assert_equal "text", field.type
    assert_equal true, field.required
    assert_redirected_to checkout_form_path
    assert_equal "Changes saved!", flash[:notice]
  end
end
