# frozen_string_literal: true

require "test_helper"

class UpdatePayoutStatusWorkerTest < ActiveSupport::TestCase
  def setup
    @paypal_calls = []
    @paypal_returns = []
  end

  def stub_get_latest_state(returns)
    @paypal_returns = Array(returns).dup
    PaypalPayoutProcessor.define_singleton_method(:get_latest_payment_state_from_paypal) do |*args|
      UpdatePayoutStatusWorkerTest.class_variable_get(:@@last_test).record_paypal_call(args)
      UpdatePayoutStatusWorkerTest.class_variable_get(:@@last_test).next_paypal_return
    end
    self.class.class_variable_set(:@@last_test, self)
  end

  def record_paypal_call(args); @paypal_calls << args; end
  def next_paypal_return; @paypal_returns.shift; end

  def teardown
    if PaypalPayoutProcessor.singleton_class.method_defined?(:get_latest_payment_state_from_paypal)
      PaypalPayoutProcessor.singleton_class.send(:remove_method, :get_latest_payment_state_from_paypal)
    end
    if PaypalPayoutProcessor.singleton_class.method_defined?(:update_split_payment_state)
      PaypalPayoutProcessor.singleton_class.send(:remove_method, :update_split_payment_state)
    end
  end

  test "fetches and sets new payment status from PayPal (non-split)" do
    payment = payments(:paypal_payment_recent)
    payment.update!(processor_fee_cents: 10, txn_id: "Some ID")
    stub_get_latest_state(["completed"])

    UpdatePayoutStatusWorker.new.perform(payment.id)

    assert_equal "completed", payment.reload.state
    args = @paypal_calls.first
    assert_equal payment.amount_cents, args[0]
    assert_equal "Some ID", args[1]
  end

  test "does not act on non-processing payments" do
    payment = payments(:paypal_payment_recent)
    payment.update!(processor_fee_cents: 10, txn_id: "Some ID")
    payment.mark_completed!
    stub_get_latest_state([])

    UpdatePayoutStatusWorker.new.perform(payment.id)

    assert_equal "completed", payment.reload.state
    assert_empty @paypal_calls
  end

  test "split mode: fetches state for pending parts and completes payment" do
    payment = payments(:paypal_payment_recent)
    payment.update!(processor_fee_cents: 10)
    payment.was_created_in_split_mode = true
    payment.split_payments_info = [
      { "unique_id" => "SPLIT_1-1", "state" => "completed", "correlation_id" => "fcf", "amount_cents" => 100, "errors" => [], "txn_id" => "02P" },
      { "unique_id" => "SPLIT_1-2", "state" => "pending", "correlation_id" => "6db", "amount_cents" => 50, "errors" => [], "txn_id" => "4LR" }
    ]
    payment.save!

    update_split_called = false
    PaypalPayoutProcessor.define_singleton_method(:update_split_payment_state) { |_p| update_split_called = true }
    stub_get_latest_state(["completed"])

    UpdatePayoutStatusWorker.new.perform(payment.id)

    args = @paypal_calls.first
    assert_equal 50, args[0]
    assert_equal "4LR", args[1]
    assert_equal "pending", args[3]
    assert update_split_called
    payment.reload
    assert_equal "completed", payment.split_payments_info[1]["state"]
  end

  test "split mode: raises if a part is still pending after fetch" do
    payment = payments(:paypal_payment_recent)
    payment.update!(processor_fee_cents: 10)
    payment.was_created_in_split_mode = true
    payment.split_payments_info = [
      { "unique_id" => "SPLIT_1-1", "state" => "completed", "correlation_id" => "fcf", "amount_cents" => 100, "errors" => [], "txn_id" => "02P" },
      { "unique_id" => "SPLIT_1-2", "state" => "pending", "correlation_id" => "6db", "amount_cents" => 50, "errors" => [], "txn_id" => "4LR" }
    ]
    payment.save!
    stub_get_latest_state(["pending"])

    err = assert_raises(RuntimeError) { UpdatePayoutStatusWorker.new.perform(payment.id) }
    assert_match(/pending/, err.message)
  end

  test "split mode: does not act on non-processing payments" do
    payment = payments(:paypal_payment_recent)
    payment.update!(processor_fee_cents: 10, txn_id: "something")
    payment.was_created_in_split_mode = true
    payment.split_payments_info = [
      { "unique_id" => "SPLIT_1-1", "state" => "completed", "amount_cents" => 100, "txn_id" => "02P" },
      { "unique_id" => "SPLIT_1-2", "state" => "pending", "amount_cents" => 50, "txn_id" => "4LR" }
    ]
    payment.save!
    payment.mark_completed!
    stub_get_latest_state([])

    UpdatePayoutStatusWorker.new.perform(payment.id)

    assert_equal "completed", payment.reload.state
    assert_empty @paypal_calls
  end
end
