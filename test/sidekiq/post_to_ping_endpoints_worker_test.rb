# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/post_to_ping_endpoints_worker_spec.rb (76 FactoryBot refs, 683 lines).
#
# Blocker for batch B backfill: Largest spec in batch B (683 lines, 76 FB refs). Builds a recommended_product + purchase + offer_code + ping_notification graph and asserts on `RestClient.post` payload shapes across 15+ branches (recommended/non-recommended, refunded/disputed/chargedback, with/without offer_code, free trial, preorder, subscription cancellation). Each branch needs distinct purchase fixture shape + WebMock `stub_request(:post, ...).to_return(status: 200)` × per endpoint URL. Skill rule P-M3: >40 FB → skip-batch (this is at 76).
class PostToPingEndpointsWorkerTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/post_to_ping_endpoints_worker_spec.rb — Largest spec in batch B (683 lines, 76 FB refs). Builds a recommended_product + purchase + offer_code + ping_notification graph and asserts on `RestClient.post` payload shapes across 15+ branches (recommended/non-recommended, refunded/disputed/chargedback, with/without offer_code, free trial, preorder, subscription cancellation). Each branch nee..."
  end
end
