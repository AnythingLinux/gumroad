# frozen_string_literal: true

require "test_helper"

class Purchases::PingsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    boot_controller_test!
    @seller = users(:named_seller)
    @admin = users(:admin_for_named_seller)
    @purchase = purchases(:named_seller_call_purchase)
  end

  teardown { restore_protect_against_forgery! }

  test "POST create returns 404 when unauthenticated" do
    called = false
    orig = Purchase.instance_method(:send_notification_webhook_from_ui)
    Purchase.define_method(:send_notification_webhook_from_ui) { called = true }
    begin
      post :create, format: :json, params: { purchase_id: @purchase.external_id }
    ensure
      Purchase.define_method(:send_notification_webhook_from_ui, orig)
    end
    refute called
    assert_response :not_found
  end

  test "POST create returns 404 when signed in as a different seller" do
    sign_in_as_seller(users(:basic_user))
    called = false
    orig = Purchase.instance_method(:send_notification_webhook_from_ui)
    Purchase.define_method(:send_notification_webhook_from_ui) { called = true }
    begin
      post :create, format: :json, params: { purchase_id: @purchase.external_id }
    ensure
      Purchase.define_method(:send_notification_webhook_from_ui, orig)
    end
    refute called
    assert_response :not_found
  end

  test "POST create resends the ping and responds with success when signed in as the seller's admin" do
    sign_in_as_seller(@admin, @seller)
    called = false
    orig = Purchase.instance_method(:send_notification_webhook_from_ui)
    Purchase.define_method(:send_notification_webhook_from_ui) { called = true }
    begin
      post :create, format: :json, params: { purchase_id: @purchase.external_id }
    ensure
      Purchase.define_method(:send_notification_webhook_from_ui, orig)
    end
    assert called
    assert_response :no_content
  end
end
