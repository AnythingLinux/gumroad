# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/charge_declined_reminder_worker_spec.rb (3 FactoryBot refs, 71 lines).
#
# Blocker for batch B backfill: Spec is `:vcr`-tagged and chains `create(:membership_purchase)` → subscription → `credit_card` factory and asserts on enqueued `CustomerLowPriorityMailer.subscription_charge_declined` mails. Needs the same membership_purchase fixture roster as send_last_post_job + a VCR-stub harness for the Stripe charge-decline path. Both are out of scope.
class ChargeDeclinedReminderWorkerTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/charge_declined_reminder_worker_spec.rb — Spec is `:vcr`-tagged and chains `create(:membership_purchase)` → subscription → `credit_card` factory and asserts on enqueued `CustomerLowPriorityMailer.subscription_charge_declined` mails. Needs the same membership_purchase fixture roster as send_last_post_job + a VCR-stub harness for the Stripe charge-decline path. Both are out of scope."
  end
end
