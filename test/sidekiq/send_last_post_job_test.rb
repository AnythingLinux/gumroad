# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/send_last_post_job_spec.rb (14 FactoryBot refs, 79 lines).
#
# Blocker for batch B backfill: Every example builds `create(:membership_product)` + `create(:membership_purchase, tier:)` + `create(:post, :published)` / `create(:variant_post, :published)` / `create(:seller_post, :published)` across 7+ negative fixtures. `:membership_product` cascades into Link + recurring price + tier_category + variants; `:membership_purchase` further requires Subscription + PaymentOption + credit_card (skill `P-subscription-create-blows-up` — Subscription.create! and save!(validate:false) both raise on missing PaymentOption). No `installments/posts` fixtures cover `:variant_post` / `:seller_post` shapes.
class SendLastPostJobTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/send_last_post_job_spec.rb — Every example builds `create(:membership_product)` + `create(:membership_purchase, tier:)` + `create(:post, :published)` / `create(:variant_post, :published)` / `create(:seller_post, :published)` across 7+ negative fixtures. `:membership_product` cascades into Link + recurring price + tier_category + variants; `:membership_purchase` further requ..."
  end
end
