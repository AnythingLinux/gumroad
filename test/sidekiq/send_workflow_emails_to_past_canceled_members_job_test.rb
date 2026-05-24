# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/send_workflow_emails_to_past_canceled_members_job_spec.rb (23 FactoryBot refs, 115 lines).
#
# Blocker for batch B backfill: Every example builds `create(:subscription_product)` + workflow + installment + installment_rule + `create(:subscription, cancelled_at:, deactivated_at:)` + `create(:purchase, is_original_subscription_purchase: true, ...)`. Same membership/subscription chain blocker as send_last_post_job. Assertions use `have_enqueued_sidekiq_job(...).immediately` / `.at(time)` — needs the `SendWorkflowInstallmentWorker.jobs` Sidekiq testing API which is loaded via spec_helper, plus an Active::Support time-zone aware port of `.at(deactivated_at + 14.days)` ordering.
class SendWorkflowEmailsToPastCanceledMembersJobTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/send_workflow_emails_to_past_canceled_members_job_spec.rb — Every example builds `create(:subscription_product)` + workflow + installment + installment_rule + `create(:subscription, cancelled_at:, deactivated_at:)` + `create(:purchase, is_original_subscription_purchase: true, ...)`. Same membership/subscription chain blocker as send_last_post_job. Assertions use `have_enqueued_sidekiq_job(...).immediatel..."
  end
end
