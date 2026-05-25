require "test_helper"

# TODO: Migrate from RSpec. BalanceTransaction spec is `:vcr`-tagged at the
# top level, 1478 LOC and 22 create() refs threading purchases / refunds /
# disputes / affiliate credits / payments through real Stripe (and PayPal)
# fee calculations under VCR cassettes. The BalanceTransaction::Amount and
# BalanceTransaction::HoldingAmount calculation matrix in particular needs
# faithful Stripe charge / refund objects. Out of scope for mechanical model
# backfill — would need ~30 VCR cassettes ported to Minitest harness.
#
# Original spec: spec/models/balance_transaction_spec.rb
class BalanceTransactionTest < ActiveSupport::TestCase
  test "TODO: migrate — :vcr + Stripe/PayPal fee math, 1478 LOC" do
    skip "Top-level :vcr; 22 create() across purchases/refunds/disputes/affiliate_credits; Stripe + PayPal fee threading. Out of scope for mechanical model backfill."
  end
end
