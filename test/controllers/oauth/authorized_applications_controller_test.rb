# frozen_string_literal: true

require "test_helper"

class Oauth::AuthorizedApplicationsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    boot_controller_test!
    @user = users(:named_seller)
    @application = oauth_applications(:notion_app_for_named_seller)
    Doorkeeper::AccessToken.create!(
      resource_owner_id: @user.id,
      application: @application,
      scopes: "creator_api"
    )
    sign_in @user
  end

  teardown { restore_protect_against_forgery! }

  test "GET index redirects to settings_authorized_applications_path" do
    get :index
    assert_redirected_to settings_authorized_applications_path
  end

  test "DELETE destroy revokes access to the authorized application and redirects" do
    assert_difference -> { OauthApplication.authorized_for(@user).count }, -1 do
      delete :destroy, params: { id: @application.external_id }
    end
    assert_redirected_to settings_authorized_applications_path
    assert_equal "Authorized application revoked", flash[:notice]
  end

  test "DELETE destroy with invalid id flashes an error and redirects" do
    delete :destroy, params: { id: "invalid_id" }
    assert_redirected_to settings_authorized_applications_path
    assert_equal "Authorized application could not be revoked", flash[:alert]
  end
end
