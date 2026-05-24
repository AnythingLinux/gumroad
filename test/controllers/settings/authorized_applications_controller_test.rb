# frozen_string_literal: true

require "test_helper"
require "support/controller_seller_auth_helpers"

class Settings::AuthorizedApplicationsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @seller = users(:named_seller)
    @admin = users(:admin_for_named_seller)
    sign_in_as_seller(@admin, @seller)
    @request.headers["X-Inertia"] = "true"
  end

  teardown { restore_protect_against_forgery! }

  test "GET index returns http success and renders Inertia component" do
    get :index
    assert_response :success
    page = JSON.parse(@response.body)
    assert_equal "Settings/AuthorizedApplications/Index", page["component"]
    assert page["props"].key?("authorized_applications")
  end
end
