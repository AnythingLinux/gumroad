# frozen_string_literal: true

require "test_helper"

class LicensesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @seller = users(:named_seller)
    @admin = users(:admin_for_named_seller)
    @license = licenses(:admin_lookup_license)
    sign_in_as_seller(@admin, @seller)
  end

  teardown { restore_protect_against_forgery! }

  test "PUT update disables the license when enabled=false" do
    assert_nil @license.disabled_at
    put :update, format: :json, params: { id: @license.external_id, enabled: false }
    assert_response :success
    assert_not_nil @license.reload.disabled_at
  end

  test "PUT update re-enables the license when enabled=true" do
    @license.update_column(:disabled_at, Time.current)
    put :update, format: :json, params: { id: @license.external_id, enabled: true }
    assert_response :success
    assert_nil @license.reload.disabled_at
  end
end
