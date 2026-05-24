# frozen_string_literal: true

require "test_helper"

class ConsumptionAnalyticsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @product = links(:pdf_stamping_product)
    @product_file = product_files(:pdf_stamping_file_one)
    @purchase = purchases(:pdf_stamping_purchase)
    @url_redirect = url_redirects(:pdf_stamping_url_redirect)

    # Build a second url_redirect without a purchase (one row, no fixture needed).
    @purchaseless_url_redirect = UrlRedirect.create!(
      link: @product, token: "no-purchase-#{SecureRandom.hex(4)}"
    )
  end

  test "successfully creates consumption event" do
    params = {
      event_type: "read",
      product_file_id: @product_file.external_id,
      url_redirect_id: @url_redirect.external_id,
      purchase_id: @purchase.external_id,
      platform: "android",
      consumed_at: "2015-09-09T17:26:50PDT"
    }
    post :create, params: params
    assert response.parsed_body["success"]
    event = ConsumptionEvent.last
    assert_equal "read", event.event_type
    assert_equal @product_file.id, event.product_file_id
    assert_equal @url_redirect.id, event.url_redirect_id
    assert_equal @purchase.id, event.purchase_id
    assert_equal @product.id, event.link_id
    assert_equal "android", event.platform
    assert_equal Time.parse("2015-09-09T17:26:50PDT"), event.consumed_at
  end

  test "uses the url_redirect's purchase id if one is not provided" do
    params = {
      event_type: "read",
      product_file_id: @product_file.external_id,
      url_redirect_id: @url_redirect.external_id,
      platform: "android"
    }
    post :create, params: params
    assert response.parsed_body["success"]
    assert_equal @purchase.id, ConsumptionEvent.last.purchase_id
  end

  test "creates a consumption event with a url_redirect that does not have a purchase" do
    params = {
      event_type: "read",
      product_file_id: @product_file.external_id,
      url_redirect_id: @purchaseless_url_redirect.external_id,
      platform: "android"
    }
    post :create, params: params
    assert response.parsed_body["success"]
    assert_nil ConsumptionEvent.last.purchase_id
  end

  test "creates a consumption event with consumed_at set to current_time if missing" do
    travel_to Time.current do
      params = {
        event_type: "read",
        product_file_id: @product_file.external_id,
        url_redirect_id: @url_redirect.external_id,
        purchase_id: @purchase.external_id,
        platform: "android"
      }
      post :create, params: params
      assert response.parsed_body["success"]
      assert_equal Time.current.to_i, ConsumptionEvent.last.consumed_at.to_i
    end
  end

  test "returns failed response if event_type is invalid" do
    params = {
      event_type: "location_watch",
      product_file_id: @product_file.external_id,
      url_redirect_id: @url_redirect.external_id,
      purchase_id: @purchase.external_id,
      platform: "web"
    }
    post :create, params: params
    refute response.parsed_body["success"]
  end
end
