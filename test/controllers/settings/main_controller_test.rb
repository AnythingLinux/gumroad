# frozen_string_literal: true

require "test_helper"
require "support/controller_seller_auth_helpers"

class Settings::MainControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    WebMock.stub_request(:get, %r{api\.pwnedpasswords\.com/range/.*}).to_return(status: 200, body: "")
    @seller = users(:named_seller)
    sign_in_as_seller(@seller)
    @request.headers["X-Inertia"] = "true"
  end

  teardown { restore_protect_against_forgery! }

  test "GET show returns success and renders Settings/Main/Show" do
    get :show
    assert_response :success
    page = JSON.parse(@response.body)
    assert_equal "Settings/Main/Show", page["component"]
  end

  test "PUT update submits successfully" do
    put :update, params: {
      user: {
        seller_refund_policy: { max_refund_period_in_days: "30", fine_print: nil },
        email: "hello@example.com",
      }
    }
    assert_redirected_to settings_main_path
    assert_response :see_other
    assert_equal "Your account has been updated!", flash[:notice]
    assert_equal "hello@example.com", @seller.reload.unconfirmed_email
  end

  test "PUT update returns error message when StandardError raised" do
    User.define_method(:save!) { |*_a| raise StandardError, "boom" }
    begin
      put :update, params: { user: { email: "hello@example.com" } }
    ensure
      User.remove_method(:save!) if User.instance_methods(false).include?(:save!)
    end
    assert_redirected_to settings_main_path
    assert_response :found
    assert_equal "Something broke. We're looking into what happened. Sorry about this!", flash[:alert]
  end

  test "PUT update sets error message on invalid record (bad email)" do
    put :update, params: { user: { email: "BAD EMAIL" } }
    assert_redirected_to settings_main_path
    assert_equal "Email is invalid", flash[:alert]
  end
end
