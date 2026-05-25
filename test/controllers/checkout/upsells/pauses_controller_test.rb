# frozen_string_literal: true

require "test_helper"
require "support/controller_seller_auth_helpers"

class Checkout::Upsells::PausesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @seller = users(:named_seller)
    sign_in_as_seller(@seller)
    @unpaused_upsell = upsells(:named_seller_upsell).tap { |u| u.update_columns(paused: false) }
  end

  teardown { restore_protect_against_forgery! }

  test "POST create pauses the upsell" do
    assert_changes -> { @unpaused_upsell.reload.paused }, from: false, to: true do
      post :create, params: { upsell_id: @unpaused_upsell.external_id }, as: :json
    end
    assert_response :no_content
  end

  test "POST create raises RecordNotFound when upsell doesn't exist" do
    assert_raises(ActiveRecord::RecordNotFound) do
      post :create, params: { upsell_id: "nonexistent" }, as: :json
    end
  end

  test "DELETE destroy unpauses the upsell" do
    @unpaused_upsell.update_columns(paused: true)
    assert_changes -> { @unpaused_upsell.reload.paused }, from: true, to: false do
      delete :destroy, params: { upsell_id: @unpaused_upsell.external_id }, as: :json
    end
    assert_response :no_content
  end

  test "DELETE destroy raises RecordNotFound when upsell doesn't exist" do
    assert_raises(ActiveRecord::RecordNotFound) do
      delete :destroy, params: { upsell_id: "nonexistent" }, as: :json
    end
  end
end
