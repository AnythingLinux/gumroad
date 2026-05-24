# frozen_string_literal: true

require "test_helper"

class Settings::PasswordControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    # Stub Devise pwned_password HTTP call FIRST — User#save triggers it.
    WebMock.stub_request(:get, %r{api\.pwnedpasswords\.com/range/.*}).to_return(status: 200, body: "")
    @user = users(:basic_user)
    @password = "test-password-123!"
    sign_in @user
    @request.headers["X-Inertia"] = "true"
    @orig_protect = ActionController::Base.instance_method(:protect_against_forgery?)
    ActionController::Base.define_method(:protect_against_forgery?) { false }
  end

  teardown do
    ActionController::Base.define_method(:protect_against_forgery?, @orig_protect) if @orig_protect
  end

  test "GET show returns http success and renders Inertia component" do
    get :show
    assert_response :success
    page = JSON.parse(@response.body)
    assert_equal "Settings/Password/Show", page["component"]
    assert_equal @user.provider.blank?, page["props"]["require_old_password"]
  end

  test "PUT update with missing payload redirects with Incorrect password alert" do
    put :update
    assert_redirected_to settings_password_path
    assert_equal "Incorrect password.", flash[:alert]
  end

  test "PUT update with valid new password redirects with success notice" do
    put :update, params: { user: { password: @password, new_password: "#{@password}-new" } }
    assert_redirected_to settings_password_path
    assert_response :see_other
    assert_equal "You have successfully changed your password.", flash[:notice]
  end

  test "PUT update invalidates active sessions and keeps current session active" do
    travel_to(DateTime.current) do
      assert_nil @user.reload.last_active_sessions_invalidated_at
      put :update, params: { user: { password: @password, new_password: "#{@password}-new" } }
      assert_in_delta DateTime.current.to_i, @user.reload.last_active_sessions_invalidated_at.to_i, 1
      assert_redirected_to settings_password_path
      assert_response :see_other
      assert_equal DateTime.current.to_i, @request.env["warden"].session["last_sign_in_at"]
    end
  end

  test "PUT update for social-account user does not require old password" do
    @user.update!(provider: "facebook")
    put :update, params: { user: { password: "", new_password: "social-new-password-123!" } }
    assert_redirected_to settings_password_path
    assert_response :see_other
    assert_equal "You have successfully changed your password.", flash[:notice]
  end
end
