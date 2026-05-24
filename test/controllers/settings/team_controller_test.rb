# frozen_string_literal: true

require "test_helper"
require "support/controller_seller_auth_helpers"

class Settings::TeamControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @seller = users(:named_seller)
    @admin = users(:admin_for_named_seller)
    sign_in_as_seller(@admin, @seller)
    @request.headers["X-Inertia"] = "true"
  end

  teardown { restore_protect_against_forgery! }

  test "GET show returns success and renders Settings/Team/Show with expected props" do
    get :show
    assert_response :success
    page = JSON.parse(@response.body)
    assert_equal "Settings/Team/Show", page["component"]
    assert page["props"]["member_infos"].is_a?(Array)
    assert_includes [true, false], page["props"]["can_invite_member"]
  end

  test "GET show redirects when seller has no email" do
    @seller.update_columns(provider: "twitter", twitter_user_id: "123", email: nil)
    get :show
    assert_redirected_to settings_main_path
    assert_equal "Your Gumroad account doesn't have an email associated. Please assign and verify your email, and try again.", flash[:alert]
  end
end
