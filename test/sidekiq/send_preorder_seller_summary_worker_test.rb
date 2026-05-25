# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/send_preorder_seller_summary_worker_spec.rb (9 FactoryBot refs, 72 lines).
#
# Blocker for batch B backfill: `:vcr`-tagged. Builds `:product` + `:preorder_product_with_content` + `:chargeable` (Stripe live token) + `:chargeable_success_charge_decline` and runs `preorder.charge!` through the real charge pipeline. Needs Stripe VCR cassettes + the chargeable Stripe-token factory chain. Same family as charge_declined_reminder_worker.
class SendPreorderSellerSummaryWorkerTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/send_preorder_seller_summary_worker_spec.rb — `:vcr`-tagged. Builds `:product` + `:preorder_product_with_content` + `:chargeable` (Stripe live token) + `:chargeable_success_charge_decline` and runs `preorder.charge!` through the real charge pipeline. Needs Stripe VCR cassettes + the chargeable Stripe-token factory chain. Same family as charge_declined_reminder_worker."
  end
end
