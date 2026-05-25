# frozen_string_literal: true

require "test_helper"
require "support/controller_seller_auth_helpers"

class Settings::ThirdPartyAnalyticsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @seller = users(:named_seller)
    @admin = users(:admin_for_named_seller)
    sign_in_as_seller(@admin, @seller)
    @request.headers["X-Inertia"] = "true"
  end

  teardown { restore_protect_against_forgery! }

  test "GET show returns success and renders Settings/ThirdPartyAnalytics/Show" do
    get :show
    assert_response :success
    page = JSON.parse(@response.body)
    assert_equal "Settings/ThirdPartyAnalytics/Show", page["component"]
    assert page["props"].key?("third_party_analytics")
    assert page["props"].key?("products")
  end

  test "PUT update succeeds with valid params" do
    put :update, params: {
      user: {
        disable_third_party_analytics: false,
        google_analytics_id: "G-1234567",
        facebook_pixel_id: "123456789",
        tiktok_pixel_id: "CFH83AJC77UUUGLE2TJG",
        skip_free_sale_analytics: true,
        enable_verify_domain_third_party_services: true,
        facebook_meta_tag: '<meta name="facebook-domain-verification" content="dkd8382hfdjs" />',
      }
    }
    assert_redirected_to settings_third_party_analytics_path
    assert_response :see_other
    assert_equal "Changes saved!", flash[:notice]
    @seller.reload
    assert_equal "G-1234567", @seller.google_analytics_id
    assert_equal "123456789", @seller.facebook_pixel_id
    assert_equal "CFH83AJC77UUUGLE2TJG", @seller.tiktok_pixel_id
  end

  test "PUT update with invalid google_analytics_id returns error and does not persist" do
    put :update, params: {
      user: {
        google_analytics_id: "bad",
      }
    }
    assert_redirected_to settings_third_party_analytics_path
    assert_response :found
    assert_equal "Please enter a valid Google Analytics ID", flash[:alert]
    assert_nil @seller.reload.google_analytics_id
  end

  test "PUT update with invalid tiktok pixel id returns error" do
    put :update, params: { user: { tiktok_pixel_id: "invalid-pixel!" } }
    assert_redirected_to settings_third_party_analytics_path
    assert_equal "Please enter a valid TikTok Pixel ID", flash[:alert]
    assert_nil @seller.reload.tiktok_pixel_id
  end
end
