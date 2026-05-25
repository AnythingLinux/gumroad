# frozen_string_literal: true

require "test_helper"

class OfferCodesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    boot_controller_test!
    @seller = users(:named_seller)
    @product = links(:named_seller_product) # price_cents 100
    @offer_code = OfferCode.create!(user: @seller, code: "octest", amount_cents: 50, max_purchase_count: 2)
    OfferCode.connection.insert(
      "INSERT INTO offer_codes_products (offer_code_id, product_id) VALUES (#{@offer_code.id}, #{@product.id})"
    )
    @offer_code_params = {
      code: @offer_code.code,
      products: { @product.unique_permalink => { permalink: @product.unique_permalink, quantity: 2 } }
    }
  end

  teardown { restore_protect_against_forgery! }

  test "returns invalid_offer error when offer code is invalid" do
    params = @offer_code_params.merge(code: "invalid_offer")
    get :compute_discount, params: params
    assert_equal(
      { "error_message" => "Sorry, the discount code you wish to use is invalid.", "error_code" => "invalid_offer", "valid" => false },
      response.parsed_body
    )
  end

  test "returns sold_out error when offer code is sold out" do
    @offer_code.update_attribute(:max_purchase_count, 0)
    get :compute_discount, params: @offer_code_params
    assert_equal(
      { "error_message" => "Sorry, the discount code you wish to use has expired.", "error_code" => "sold_out", "valid" => false },
      response.parsed_body
    )
  end

  test "returns products_data for a valid offer code" do
    get :compute_discount, params: @offer_code_params
    assert_equal({
      "valid" => true,
      "products_data" => {
        @product.unique_permalink => {
          "type" => "fixed", "cents" => @offer_code.amount,
          "product_ids" => [@product.external_id],
          "minimum_quantity" => nil, "expires_at" => nil,
          "duration_in_billing_cycles" => nil, "minimum_amount_cents" => nil
        }
      }
    }, response.parsed_body)
  end

  test "returns products_data when universal code amount exceeds price but applies in a bundle" do
    other_product = links(:basic_user_product)
    universal_code = OfferCode.create!(user: other_product.user, code: "univtest", amount_cents: other_product.price_cents + 100, universal: true)
    params = {
      code: universal_code.code,
      products: { other_product.unique_permalink => { permalink: other_product.unique_permalink, quantity: 2 } }
    }
    get :compute_discount, params: params
    assert_equal({
      "valid" => true,
      "products_data" => {
        other_product.unique_permalink => {
          "cents" => other_product.price_cents + 100, "type" => "fixed",
          "product_ids" => nil, "minimum_quantity" => nil, "expires_at" => nil,
          "duration_in_billing_cycles" => nil, "minimum_amount_cents" => nil
        }
      }
    }, response.parsed_body)
  end
end
