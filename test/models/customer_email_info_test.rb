# frozen_string_literal: true

require "test_helper"

class CustomerEmailInfoTest < ActiveSupport::TestCase
  setup do
    @purchase = purchases(:auto_invoice_enabled_purchase)
    @charge = charges(:admin_charge_policy_charge)
  end

  # ---- .find_or_initialize_for_charge ----

  test ".find_or_initialize_for_charge initializes a new record when none exists" do
    email_info = CustomerEmailInfo.find_or_initialize_for_charge(
      charge_id: @charge.id,
      email_name: SendgridEventInfo::RECEIPT_MAILER_METHOD
    )
    refute email_info.persisted?
    assert_equal SendgridEventInfo::RECEIPT_MAILER_METHOD, email_info.email_name
    assert_equal @charge.id, email_info.charge_id
    assert_nil email_info.purchase_id
  end

  test ".find_or_initialize_for_charge finds existing record" do
    expected = CustomerEmailInfo.create!(
      email_name: SendgridEventInfo::RECEIPT_MAILER_METHOD,
      purchase_id: nil,
      email_info_charge_attributes: { charge_id: @charge.id }
    )
    email_info = CustomerEmailInfo.find_or_initialize_for_charge(
      charge_id: @charge.id,
      email_name: SendgridEventInfo::RECEIPT_MAILER_METHOD
    )
    assert_equal expected, email_info
    assert_equal @charge.id, email_info.charge_id
    assert_nil email_info.purchase_id
  end

  # ---- .find_or_initialize_for_purchase ----

  test ".find_or_initialize_for_purchase initializes a new record when none exists" do
    email_info = CustomerEmailInfo.find_or_initialize_for_purchase(
      purchase_id: @purchase.id,
      email_name: SendgridEventInfo::RECEIPT_MAILER_METHOD
    )
    refute email_info.persisted?
    assert_equal SendgridEventInfo::RECEIPT_MAILER_METHOD, email_info.email_name
    assert_equal @purchase.id, email_info.purchase_id
    assert_nil email_info.charge_id
  end

  test ".find_or_initialize_for_purchase finds existing record" do
    expected = CustomerEmailInfo.create!(
      email_name: SendgridEventInfo::RECEIPT_MAILER_METHOD,
      purchase: @purchase
    )
    email_info = CustomerEmailInfo.find_or_initialize_for_purchase(
      purchase_id: @purchase.id,
      email_name: SendgridEventInfo::RECEIPT_MAILER_METHOD
    )
    assert_equal expected, email_info
    assert_equal @purchase.id, email_info.purchase_id
    assert_nil email_info.charge_id
  end

  # ---- state transitions ----

  test "transitions to sent" do
    email_info = CustomerEmailInfo.create!(purchase: @purchase, email_name: "receipt", state: "created")
    assert_equal "receipt", email_info.email_name
    email_info.update_attribute(:delivered_at, Time.current)
    email_info.mark_sent!
    email_info.reload
    assert_equal "sent", email_info.state
    assert_predicate email_info.sent_at, :present?
    assert_nil email_info.delivered_at
  end

  test "transitions to delivered" do
    email_info = CustomerEmailInfo.create!(
      purchase: @purchase, email_name: "receipt", state: "sent", sent_at: Time.current
    )
    assert_predicate email_info.sent_at, :present?
    assert_nil email_info.delivered_at
    assert_nil email_info.opened_at
    email_info.mark_delivered!
    email_info.reload
    assert_equal "delivered", email_info.state
    assert_predicate email_info.delivered_at, :present?
  end

  test "transitions to opened" do
    email_info = CustomerEmailInfo.create!(
      purchase: @purchase, email_name: "receipt", state: "delivered",
      sent_at: Time.current, delivered_at: Time.current
    )
    assert_predicate email_info.sent_at, :present?
    assert_predicate email_info.delivered_at, :present?
    assert_nil email_info.opened_at
    email_info.mark_opened!
    email_info.reload
    assert_equal "opened", email_info.state
    assert_predicate email_info.opened_at, :present?
  end

  # ---- #mark_bounced! ----

  test "#mark_bounced! attempts to unsubscribe the buyer" do
    email_info = CustomerEmailInfo.create!(
      purchase: @purchase, email_name: "receipt", state: "delivered",
      sent_at: Time.current, delivered_at: Time.current
    )
    called = 0
    purchase_inst = email_info.purchase
    purchase_inst.define_singleton_method(:unsubscribe_buyer) { called += 1 }
    email_info.define_singleton_method(:purchase) { purchase_inst }
    email_info.mark_bounced!
    assert_equal 1, called
  end
end
