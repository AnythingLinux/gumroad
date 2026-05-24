# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Backfill batch C kept skip-stub.
# Original spec: spec/modules/user/ping_notification_spec.rb (111 lines)
# Blockers (three net-new fixture tables required):
#   * `purchase_custom_fields` — `@purchase.purchase_custom_fields << build(...)`
#     for the URL-encoded brackets test. No fixture file exists; need
#     test/fixtures/purchase_custom_fields.yml with a row keyed off
#     purchases(:basic_purchase) (or similar).
#   * `doorkeeper/access_tokens` — `create("doorkeeper/access_token", ...)`.
#     No fixture file exists. Doorkeeper stores under `oauth_access_tokens`.
#   * `resource_subscriptions` — `create(:resource_subscription, ...)` with
#     post_url + content_type + resource_name. No fixture file exists.
# Plus `HTTParty.receive(:post).with(...)` mocha-shaped expectations on three
# tests. Migrate once the three fixture tables are added in a follow-up.
class UserPingNotificationTest < ActiveSupport::TestCase
  test "skipped: needs purchase_custom_fields + doorkeeper access_tokens + resource_subscriptions fixtures (3 net-new tables)" do
    skip "TODO: spec/modules/user/ping_notification_spec.rb needs 3 net-new fixture files"
  end
end
