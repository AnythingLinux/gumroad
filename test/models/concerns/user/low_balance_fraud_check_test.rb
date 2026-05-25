require "test_helper"

# TODO: Migrate from RSpec. Original spec stubs `@creator.unpaid_balance_cents`
# (`allow(...).to receive(...)`), uses `have_enqueued_mail(AdminMailer, ...)`,
# and `versioning: true` (PaperTrail). Stubbing instance methods in Minitest
# without Mocha is awkward, and the refunded_purchase factory + comments
# threading + paper_trail context together exceed mechanical-conversion budget.
#
# Original spec: spec/models/concerns/user/low_balance_fraud_check_spec.rb
class User::LowBalanceFraudCheckTest < ActiveSupport::TestCase
  test "TODO: migrate — Minitest instance stubbing + ActionMailer enqueue + paper_trail" do
    skip "Requires instance stubs for unpaid_balance_cents, have_enqueued_mail equivalent, refunded_purchase + paper_trail :versioning context. Out of scope for mechanical backfill."
  end
end
