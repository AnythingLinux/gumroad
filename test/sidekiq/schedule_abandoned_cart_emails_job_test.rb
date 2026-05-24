# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/schedule_abandoned_cart_emails_job_spec.rb (48 FactoryBot refs, 125 lines).
#
# Blocker for batch B backfill: Build chain: `:payment_completed` × per seller + `:product` × 2 per seller + `:variant_category` + `:variant` × 2 + `:abandoned_cart_workflow` (workflow with `bought_products` / `bought_variants` permalink arrays) + `:cart` + `:cart_product`. `abandoned_cart_workflow` factory has no fixture equivalent — the Minitest lane has zero `:cart` / `:cart_product` / `:abandoned_cart_workflow` fixtures. Plus `have_enqueued_mail(CustomerMailer, :abandoned_cart)` matcher. Out of scope.
class ScheduleAbandonedCartEmailsJobTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/schedule_abandoned_cart_emails_job_spec.rb — Build chain: `:payment_completed` × per seller + `:product` × 2 per seller + `:variant_category` + `:variant` × 2 + `:abandoned_cart_workflow` (workflow with `bought_products` / `bought_variants` permalink arrays) + `:cart` + `:cart_product`. `abandoned_cart_workflow` factory has no fixture equivalent — the Minitest lane has zero `:cart` / `:car..."
  end
end
