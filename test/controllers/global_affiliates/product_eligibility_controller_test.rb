# frozen_string_literal: true

require "test_helper"

class GlobalAffiliates::ProductEligibilityControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @seller = users(:named_seller)
    @admin = users(:admin_for_named_seller)
    sign_in_as_seller(@admin, @seller)
  end

  teardown { restore_protect_against_forgery! }

  test "GET show returns an error for an invalid URL host" do
    get :show, format: :json, params: { url: "https://example.com" }
    assert_response :success
    json = response.parsed_body
    assert_equal false, json["success"]
    assert_equal "Please provide a valid Gumroad product URL", json["error"]
  end

  test "GET show returns an error for non-ASCII characters in URL instead of raising" do
    get :show, format: :json, params: { url: "https://gumroad.com/discover.json?a=123\u201D" }
    assert_response :success
    json = response.parsed_body
    assert_equal false, json["success"]
    assert_equal "Please provide a valid Gumroad product URL", json["error"]
  end
end
