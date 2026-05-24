# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/sync_stuck_purchases_job_spec.rb (21 FactoryBot refs, 201 lines).
#
# Blocker for batch B backfill: `:vcr`-tagged. Every example builds `create(:product)` + `stub_const("GUMROAD_ADMIN_ID", create(:admin_user).id)` + a `create(:purchase, purchase_state: "in_progress", ...)` followed by `purchase.sync_status_with_charge_processor!` which hits Stripe::Charge.retrieve. Needs Stripe VCR cassettes + `:in_progress` purchase fixture (the heavy-validation Purchase model rejects in_progress without a chargeable). Out of scope alongside the other Stripe live-charge workers.
class SyncStuckPurchasesJobTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/sync_stuck_purchases_job_spec.rb — `:vcr`-tagged. Every example builds `create(:product)` + `stub_const('GUMROAD_ADMIN_ID', create(:admin_user).id)` + a `create(:purchase, purchase_state: 'in_progress', ...)` followed by `purchase.sync_status_with_charge_processor!` which hits Stripe::Charge.retrieve. Needs Stripe VCR cassettes + `:in_progress` purchase fixture (the heavy-validat..."
  end
end
