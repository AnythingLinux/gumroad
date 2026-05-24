# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/delete_stripe_apple_pay_domain_worker_spec.rb (1 FactoryBot refs, 23 lines).
#
# Blocker for batch B backfill: `:vcr`-tagged. Every example calls `Stripe::ApplePayDomain.create(domain_name: ...)` against a recorded cassette and then `StripeApplePayDomain.create!(...)` — the latter requires a `:user` fixture (trivially `users(:basic_user)`) but the former needs the Stripe-live cassette harness the Minitest lane doesn't carry. Sharpened skip-stub matches the other Stripe live-API workers (create_stripe_apple_pay_domain_worker is also skip-stubbed in mig-c).
class DeleteStripeApplePayDomainWorkerTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/delete_stripe_apple_pay_domain_worker_spec.rb — `:vcr`-tagged. Every example calls `Stripe::ApplePayDomain.create(domain_name: ...)` against a recorded cassette and then `StripeApplePayDomain.create!(...)` — the latter requires a `:user` fixture (trivially `users(:basic_user)`) but the former needs the Stripe-live cassette harness the Minitest lane doesn't carry. Sharpened skip-stub matches t..."
  end
end
