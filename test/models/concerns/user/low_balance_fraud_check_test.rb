# frozen_string_literal: true

require "test_helper"

class User::LowBalanceFraudCheckTest < ActiveSupport::TestCase
  test "TODO: migrate from spec/models/concerns/user/low_balance_fraud_check_spec.rb" do
    skip "Skip-batch: state machine transitions (suspend_for_fraud!, suspend_for_tos_violation!) " \
         "trigger heavy callbacks (Stripe Apple Pay domain, gmail abuse filter, send_suspension_email, " \
         "suspend_sellers_other_accounts, block_seller_ip!) without stubs; uses PaperTrail versioning and " \
         "stubs unpaid_balance_cents (User::Stats ES chain). Re-migrate with comprehensive User stubs."
  end
end
