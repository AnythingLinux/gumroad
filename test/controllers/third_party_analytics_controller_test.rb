# frozen_string_literal: true

require "test_helper"

class ThirdPartyAnalyticsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @seller = users(:named_seller)
    @product = links(:named_seller_product)
    @purchase = purchases(:audience_purchase)
    @product_product_snippet = ThirdPartyAnalytic.create!(user: @seller, link: @product, location: "product", analytics_code: "product product")
    @product_user_snippet    = ThirdPartyAnalytic.create!(user: @seller, link: nil, location: "product", analytics_code: "product user")
    @receipt_product_snippet = ThirdPartyAnalytic.create!(user: @seller, link: @product, location: "receipt", analytics_code: "receipt product")
    @receipt_user_snippet    = ThirdPartyAnalytic.create!(user: @seller, link: nil, location: "receipt", analytics_code: "receipt user")
    @global_product_snippet  = ThirdPartyAnalytic.create!(user: @seller, link: @product, location: "all", analytics_code: "global product")
    @global_user_snippet     = ThirdPartyAnalytic.create!(user: @seller, link: nil, location: "all", analytics_code: "global user")
  end

  test "index includes all applicable snippets for location=product" do
    get :index, params: { link_id: @product.unique_permalink, location: "product" }
    body = response.body
    assert_includes body, @product_product_snippet.analytics_code
    assert_includes body, @product_user_snippet.analytics_code
    assert_includes body, @global_user_snippet.analytics_code
    assert_includes body, @global_product_snippet.analytics_code
    refute_includes body, @receipt_user_snippet.analytics_code
    refute_includes body, @receipt_product_snippet.analytics_code
  end

  test "index includes all applicable snippets for location=receipt" do
    get :index, params: { link_id: @product.unique_permalink, purchase_id: @purchase.external_id, location: "receipt" }
    body = response.body
    assert_includes body, @receipt_user_snippet.analytics_code
    assert_includes body, @receipt_product_snippet.analytics_code
    assert_includes body, @global_user_snippet.analytics_code
    assert_includes body, @global_product_snippet.analytics_code
    refute_includes body, @product_product_snippet.analytics_code
    refute_includes body, @product_user_snippet.analytics_code
  end

  test "replaces $VALUE and $CURRENCY tokens" do
    @global_product_snippet.update!(analytics_code: "<img height='$VALUE' width='$CURRENCY' alt='' style='display:none' src='http://placehold.it/150x150' />")
    get :index, params: { link_id: @product.unique_permalink, purchase_id: @purchase.external_id, location: "receipt" }
    assert_includes response.body, "<img height='1' width='USD' alt='' style='display:none' src='http://placehold.it/150x150' />"
  end

  test "replaces $ORDER token with purchase external id" do
    @global_product_snippet.update!(analytics_code: "<img height='$ORDER' width='$CURRENCY' alt='' style='display:none' src='http://placehold.it/150x150' />")
    get :index, params: { link_id: @product.unique_permalink, purchase_id: @purchase.external_id, location: "receipt" }
    assert_includes response.body, "<img height='#{@purchase.external_id}' width='USD' alt='' style='display:none' src='http://placehold.it/150x150' />"
  end

  test "raises 404 if purchase does not belong to product" do
    other_purchase = purchases(:audience_revoked_purchase) # has different link
    other_purchase.update_columns(link_id: links(:basic_user_product).id)
    assert_raises(ActionController::RoutingError) do
      get :index, params: { link_id: @product.unique_permalink, purchase_id: other_purchase.external_id }
    end
  end

  test "raises 404 if purchase does not exist" do
    assert_raises(ActionController::RoutingError) do
      get :index, params: { link_id: @product.unique_permalink, purchase_id: "definitely-not-real" }
    end
  end
end
