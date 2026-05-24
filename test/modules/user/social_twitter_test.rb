# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Backfill batch C kept skip-stub.
# Original spec: spec/modules/user/social_twitter_spec.rb (71 lines)
# Blockers:
#   * tagged `:vcr` for `User.query_twitter` paths (recorded cassettes under
#     spec/support/fixtures/vcr_cassettes/User_SocialTwitter/...) — Minitest
#     lane has no VCR adapter wired.
#   * `expect($twitter).to receive(:user)` mocks the global $twitter client
#     (initializers/twitter.rb). The Minitest lane has no `$twitter` stub
#     pattern; would need a per-test global swap + Mocha-shaped helper.
#   * `HTTParty.get(twitter_picture_url)` performs a real S3 round trip in
#     `User#twitter_picture_url` (downloads + reuploads via ActiveStorage).
#     Requires MinIO + ActiveStorage disk-service replacement (see
#     references/leaf-backfill-pitfalls.md "ActiveStorage attachments").
# Sharpen this stub once Minitest grows a VCR shim. Covered by RSpec lane.
class User::SocialTwitterTest < ActiveSupport::TestCase
  test "skipped: VCR + $twitter global + S3 round trip not portable to Minitest lane" do
    skip "TODO: spec/modules/user/social_twitter_spec.rb needs VCR + $twitter stubbing + ActiveStorage MinIO setup"
  end
end
