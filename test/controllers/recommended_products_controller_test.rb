# frozen_string_literal: true

require "test_helper"

class RecommendedProductsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = users(:basic_user)
    sign_in @user
  end

  test "GET index calls CheckoutService and returns product cards" do
    product = links(:basic_user_product)
    cart_product = links(:named_seller_product)

    info = Struct.new(:product, :recommended_by, :target, :recommender_model_name, :affiliate_id).new(
      product, RecommendationType::GUMROAD_MORE_LIKE_THIS_RECOMMENDATION, Product::Layout::PROFILE,
      RecommendedProductsService::MODEL_SALES, nil
    )

    captured = {}
    orig = RecommendedProducts::CheckoutService.method(:fetch_for_cart)
    RecommendedProducts::CheckoutService.define_singleton_method(:fetch_for_cart) do |**kwargs|
      captured[:kwargs] = kwargs
      [info]
    end

    card_calls = []
    orig_card = ProductPresenter.method(:card_for_web)
    ProductPresenter.define_singleton_method(:card_for_web) do |**kwargs|
      card_calls << kwargs
      { "id" => kwargs[:product].id, "rec" => kwargs[:recommended_by] }
    end

    begin
      get :index,
          params: { cart_product_ids: [cart_product.external_id], on_discover_page: "false", limit: "5" },
          session: { recommender_model_name: RecommendedProductsService::MODEL_SALES }
    ensure
      RecommendedProducts::CheckoutService.singleton_class.send(:remove_method, :fetch_for_cart)
      RecommendedProducts::CheckoutService.define_singleton_method(:fetch_for_cart, orig)
      ProductPresenter.singleton_class.send(:remove_method, :card_for_web)
      ProductPresenter.define_singleton_method(:card_for_web, orig_card)
    end

    assert_response :success
    assert_equal @user, captured[:kwargs][:purchaser]
    assert_equal [cart_product.id], captured[:kwargs][:cart_product_ids]
    assert_equal 5, captured[:kwargs][:limit]
    assert_equal RecommendedProductsService::MODEL_SALES, captured[:kwargs][:recommender_model_name]
    body = response.parsed_body
    assert_equal 1, body.length
    assert_equal product.id, body.first["id"]
    assert_equal 1, card_calls.length
  end
end
