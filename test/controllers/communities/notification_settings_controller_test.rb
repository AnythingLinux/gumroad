# frozen_string_literal: true

require "test_helper"
require "support/controller_seller_auth_helpers"

class Communities::NotificationSettingsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @seller = users(:named_seller)
    @seller.save! if @seller.external_id.blank?
    @admin = users(:admin_for_named_seller)
    sign_in_as_seller(@admin, @seller)
    Feature.activate_user(:communities, @seller)
    Feature.activate_user(:communities, @admin)
    @community = communities(:named_seller_product_community)
  end

  teardown { restore_protect_against_forgery! }

  test "PUT update redirects to dashboard when communities flag is disabled" do
    Feature.deactivate_user(:communities, @admin)
    put :update, params: { community_id: @community.external_id }
    assert_redirected_to dashboard_path
    assert_equal "Your current role as Admin cannot perform this action.", flash[:alert]
  end

  test "PUT update raises RecordNotFound when community is not found" do
    sign_in_as_seller(@seller)
    Feature.activate_user(:communities, @seller)
    assert_raises(ActiveRecord::RecordNotFound) do
      put :update, params: { community_id: "nonexistent" }
    end
  end
end
