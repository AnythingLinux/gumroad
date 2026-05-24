# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Backfill batch C kept skip-stub.
# Original spec: spec/modules/product/stats_spec.rb (355 lines, 75 FB refs)
# Blockers:
#   * 4 of 5 top-level describes are tagged `:sidekiq_inline,
#     :elasticsearch_wait_for_refresh`. The Sidekiq inline tag is doable, but
#     `successful_sales_count` / `total_usd_cents` / `total_fee_cents` /
#     `monthly_recurring_revenue` rely on the live ES Link index being
#     populated by the post-purchase indexing callbacks.
#   * `partially_refunded_purchase.refund_purchase!` triggers Stripe API +
#     FlowOfFunds + balance ledger writes — needs VCR or a deep mock graph.
#   * MRR tiered-membership test pulls in `ManageSubscriptionHelpers`
#     (spec/support/helpers/manage_subscription_helpers.rb) which itself uses
#     `create(:price, ...)`, `Subscription::UpdaterService.new(...).perform`,
#     and `travel_to`. Not portable as-is.
#   * `#pending_balance` / `#revenue_pending` / `#successful_sales_count`
#     instance-method blocks (no ES tag) could migrate independently with a
#     subscription_product + subscription + original_purchase fixture trio,
#     but that itself needs the Subscription raw-INSERT escape hatch
#     (see references/leaf-backfill-pitfalls.md "Subscription.create!"). Out
#     of scope for batch C's 10-iter budget.
class ModulesProductStatsTest < ActiveSupport::TestCase
  test "skipped: ES-bound + ManageSubscriptionHelpers + Stripe refund_purchase! chain" do
    skip "TODO: spec/modules/product/stats_spec.rb (75 FB refs) needs ES + subscription fixtures + Stripe stubs"
  end
end
