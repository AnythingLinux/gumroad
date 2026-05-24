# frozen_string_literal: true

require "test_helper"
require "support/controller_seller_auth_helpers"

class Wishlists::FollowingControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @user = users(:purchaser)
    sign_in_as_seller(@user)
    Feature.activate(:follow_wishlists)
    @request.headers["X-Inertia"] = "true"
  end

  teardown { restore_protect_against_forgery! }

  test "GET index returns 404 when feature flag is off" do
    Feature.deactivate(:follow_wishlists)
    assert_raises(ActionController::RoutingError) do
      get :index
    end
  end

  test "GET index renders Wishlists/Following/Index" do
    get :index
    assert_response :success
    page = JSON.parse(@response.body)
    assert_equal "Wishlists/Following/Index", page["component"]
    assert_kind_of Array, page["props"]["wishlists"]
  end
end
