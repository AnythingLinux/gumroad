# frozen_string_literal: true

require "test_helper"

class Settings::AdvancedControllerTest < ActionController::TestCase
  tests Settings::AdvancedController
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @seller = users(:named_seller)
    @admin = users(:admin_for_named_seller)
    sign_in_as_seller(@admin, @seller)
    @request.headers["X-Inertia"] = "true"
  end

  teardown { restore_protect_against_forgery! }

  test "GET show returns success and renders Settings/Advanced/Show inertia component" do
    get :show
    assert_response :success
    page = JSON.parse(@response.body)
    assert_equal "Settings/Advanced/Show", page["component"]
    assert page["props"].is_a?(Hash)
  end

  test "PUT update with notification_endpoint succeeds and updates seller" do
    put :update, params: { user: { notification_endpoint: "https://example.com" } }
    assert_redirected_to settings_advanced_path
    assert_equal 303, response.status
    assert_equal "Your account has been updated!", flash[:notice]
    assert_equal "https://example.com", @seller.reload.notification_endpoint
  end

  test "PUT update returns alert when update raises StandardError" do
    User.define_method(:update) { |*_a, **_k| raise StandardError, "boom" }
    begin
      put :update, params: { user: { notification_endpoint: "https://example.com" } }
    ensure
      User.remove_method(:update) if User.instance_methods(false).include?(:update)
    end
    assert_redirected_to settings_advanced_path
    assert_equal "Something broke. We're looking into what happened. Sorry about this!", flash[:alert]
  end

  test "mass-block customer emails creates BlockedCustomerObject rows" do
    @seller.blocked_customer_objects.delete_all
    assert_difference -> { @seller.blocked_customer_objects.active.email.count }, 2 do
      put :update, params: {
        user: { notification_endpoint: "" },
        blocked_customer_emails: "customer1@example.com\ncustomer2@example.com",
      }
    end
    assert_redirected_to settings_advanced_path
    assert_equal "Your account has been updated!", flash[:notice]
    values = @seller.blocked_customer_objects.active.email.pluck(:object_value)
    assert_includes values, "customer1@example.com"
    assert_includes values, "customer2@example.com"
  end
end
