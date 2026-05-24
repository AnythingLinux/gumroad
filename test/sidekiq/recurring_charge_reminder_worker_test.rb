# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/recurring_charge_reminder_worker_spec.rb (0 FactoryBot refs, 57 lines).
#
# Blocker for batch B backfill: `:vcr`-tagged and `include ManageSubscriptionHelpers`. `setup_subscription` in that helper builds the full membership chain (link + price + subscription + payment_option + credit_card + original_purchase). Asserts on `have_enqueued_mail(CustomerLowPriorityMailer, :subscription_renewal_reminder)` plus `allow_any_instance_of(Subscription).to receive(:send_renewal_reminders?)` (instance-method partial stub — no native Minitest equivalent). Out of scope.
class RecurringChargeReminderWorkerTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/recurring_charge_reminder_worker_spec.rb — `:vcr`-tagged and `include ManageSubscriptionHelpers`. `setup_subscription` in that helper builds the full membership chain (link + price + subscription + payment_option + credit_card + original_purchase). Asserts on `have_enqueued_mail(CustomerLowPriorityMailer, :subscription_renewal_reminder)` plus `allow_any_instance_of(Subscription).to recei..."
  end
end
