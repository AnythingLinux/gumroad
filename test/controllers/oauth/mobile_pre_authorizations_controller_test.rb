# frozen_string_literal: true

require "test_helper"

class Oauth::MobilePreAuthorizationsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    boot_controller_test!
    @user = users(:purchaser)
  end

  teardown { restore_protect_against_forgery! }

  test "GET new (logged in) renders the pre-authorization prompt with user details and sets mobile app cookie" do
    sign_in @user
    @request.env["HTTPS"] = "on"
    get :new, params: { client_id: "abc", redirect_uri: "gumroadmobile://", response_type: "code" }
    assert_response :ok
    assert_includes response.body, @user.display_name
    assert_includes response.body, @user.email
    assert_includes response.body, "/oauth/authorize?client_id=abc&amp;redirect_uri=gumroadmobile%3A%2F%2F&amp;response_type=code"
    assert_includes response.body, "Continue"
    assert_includes response.body, "Use a different account"
    set_cookie = Array(response.headers["Set-Cookie"]).join(";")
    assert_includes set_cookie, "is_gumroad_mobile_app=1"
  end

  test "GET new (not logged in) redirects to the oauth authorize url and sets the mobile app cookie" do
    @request.env["HTTPS"] = "on"
    get :new, params: { client_id: "abc", redirect_uri: "gumroadmobile://", response_type: "code" }
    assert_redirected_to "/oauth/authorize?client_id=abc&redirect_uri=gumroadmobile%3A%2F%2F&response_type=code"
    set_cookie = Array(response.headers["Set-Cookie"]).join(";")
    assert_includes set_cookie, "is_gumroad_mobile_app=1"
  end

  test "GET switch_account signs out the user and redirects to oauth authorize" do
    sign_in @user
    get :switch_account, params: { client_id: "abc", redirect_uri: "gumroadmobile://", response_type: "code" }
    assert_equal false, @controller.user_signed_in?
    assert_redirected_to "/oauth/authorize?client_id=abc&redirect_uri=gumroadmobile%3A%2F%2F&response_type=code"
  end

  test "GET switch_account redirects when no user is signed in" do
    get :switch_account, params: { client_id: "abc", redirect_uri: "gumroadmobile://", response_type: "code" }
    assert_redirected_to "/oauth/authorize?client_id=abc&redirect_uri=gumroadmobile%3A%2F%2F&response_type=code"
  end
end
