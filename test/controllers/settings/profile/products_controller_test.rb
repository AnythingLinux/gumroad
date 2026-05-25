# frozen_string_literal: true

require "test_helper"
require "support/controller_seller_auth_helpers"

class Settings::Profile::ProductsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  test "GET show (unauthenticated) redirects to login" do
    boot_controller_test!
    get :show, params: { id: "any" }
    assert_response :found
    assert_includes @response.location, login_path
  end

  test "GET show returns props for the product" do
    @seller = users(:named_seller)
    @admin = users(:admin_for_named_seller)
    sign_in_as_seller(@admin, @seller)
    product = links(:named_seller_product)
    get :show, params: { id: product.external_id }
    assert_response :success
    json = @response.parsed_body
    # Assert the shape: product props serializer is consistent — we just check
    # a few core fields rather than full equality because URL host details depend
    # on request env (subdomain vs test.host).
    assert_equal product.unique_permalink, json["product"]["permalink"]
    assert_equal product.name, json["product"]["name"]
    assert_equal product.native_type, json["product"]["native_type"]
    assert_equal product.price_cents, json["product"]["price_cents"]
  end

  teardown { restore_protect_against_forgery! }
end
