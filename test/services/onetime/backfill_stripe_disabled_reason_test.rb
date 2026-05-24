# frozen_string_literal: true

require "test_helper"

class OnetimeBackfillStripeDisabledReasonTest < ActiveSupport::TestCase
  def fake_stripe_account(disabled_reason:)
    requirements = Struct.new(:disabled_reason).new(disabled_reason)
    requirements.define_singleton_method(:[]) { |k| disabled_reason if k.to_s == "disabled_reason" }
    account = Struct.new(:requirements).new(requirements)
    account.define_singleton_method(:[]) { |k| requirements if k.to_s == "requirements" }
    account
  end

  def stub_retrieve(map, &blk)
    Stripe::Account.stub(:retrieve, ->(id) {
      raise map[id] if map[id].is_a?(Exception)
      map.fetch(id) { fake_stripe_account(disabled_reason: nil) }
    }) do
      ReplicaLagWatcher.stub(:watch, nil) { yield }
    end
  end

  setup do
    # Use the money_balance_stripe_account (alive, non-Connect) — set a known merchant id.
    @ma = merchant_accounts(:money_balance_stripe_account)
    @ma.update_columns(charge_processor_merchant_id: "acct_target_dr", charge_processor_alive_at: Time.current, charge_processor_deleted_at: nil)
    @connect = merchant_accounts(:radar_stripe_connect_account)
    @connect.update_columns(charge_processor_merchant_id: "acct_connect_dr", charge_processor_alive_at: Time.current, charge_processor_deleted_at: nil)
    # Soft-delete all other stripe alive non-connect accounts so they don't pollute the scope.
    MerchantAccount.stripe.charge_processor_alive
      .where.not(id: [@ma.id, @connect.id])
      .where.not(charge_processor_merchant_id: nil)
      .update_all(charge_processor_deleted_at: Time.current)
  end

  test "writes the disabled_reason returned by Stripe onto the merchant account" do
    accounts = { "acct_target_dr" => fake_stripe_account(disabled_reason: "rejected.listed") }
    Stripe::Account.stub(:retrieve, ->(id) { accounts.fetch(id, fake_stripe_account(disabled_reason: nil)) }) do
      ReplicaLagWatcher.stub(:watch, nil) { Onetime::BackfillStripeDisabledReason.process }
    end
    assert_equal "rejected.listed", @ma.reload.stripe_disabled_reason
  end

  test "clears the disabled_reason when Stripe no longer reports one" do
    @ma.update!(stripe_disabled_reason: "rejected.other")
    Stripe::Account.stub(:retrieve, ->(_id) { fake_stripe_account(disabled_reason: nil) }) do
      ReplicaLagWatcher.stub(:watch, nil) { Onetime::BackfillStripeDisabledReason.process }
    end
    assert_nil @ma.reload.stripe_disabled_reason
  end

  test "skips Stripe Connect accounts" do
    @connect.update!(stripe_disabled_reason: nil)
    calls = []
    Stripe::Account.stub(:retrieve, ->(id) { calls << id; fake_stripe_account(disabled_reason: nil) }) do
      ReplicaLagWatcher.stub(:watch, nil) { Onetime::BackfillStripeDisabledReason.process }
    end
    refute_includes calls, "acct_connect_dr"
    assert_nil @connect.reload.stripe_disabled_reason
  end

  test "leaves the value untouched when it already matches what Stripe reports" do
    @ma.update!(stripe_disabled_reason: "rejected.listed")
    calls = []
    original = MerchantAccount.instance_method(:update!)
    MerchantAccount.define_method(:update!) { |*a, **kw| calls << [a, kw]; original.bind(self).call(*a, **kw) }
    begin
      Stripe::Account.stub(:retrieve, ->(_id) { fake_stripe_account(disabled_reason: "rejected.listed") }) do
        ReplicaLagWatcher.stub(:watch, nil) { Onetime::BackfillStripeDisabledReason.process }
      end
    ensure
      MerchantAccount.send(:remove_method, :update!)
      MerchantAccount.define_method(:update!, original)
    end
    refute calls.any? { |args, _kw| args.first.is_a?(Hash) && args.first.key?(:stripe_disabled_reason) }, "update! should not have been called with stripe_disabled_reason"
    assert_equal "rejected.listed", @ma.reload.stripe_disabled_reason
  end

  test "skips merchant accounts whose Stripe::Account.retrieve raises and continues with the rest" do
    Stripe::Account.stub(:retrieve, ->(id) {
      raise Stripe::APIConnectionError.new("nope") if id == "acct_target_dr"
      fake_stripe_account(disabled_reason: "rejected.fraud")
    }) do
      ReplicaLagWatcher.stub(:watch, nil) { Onetime::BackfillStripeDisabledReason.process }
    end
    assert_nil @ma.reload.stripe_disabled_reason
  end
end
