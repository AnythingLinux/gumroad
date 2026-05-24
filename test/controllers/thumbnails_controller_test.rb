# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Spec was deleted in commit c9c93ee5 during the
# big RSpec->Minitest cutover; original at spec/controllers/thumbnails_controller_spec.rb.
#
# Sharpened skip-stub reason (see PR #5257 batch A):
#   ActiveStorage::Blob.create_and_upload! + image analyze pipeline (Aws::S3::Errors::AccessDenied trap) + VCR for thumbnail validation calls. Same disk-service+Makara recipe as ActiveStorage attachment pitfall (see references/leaf-backfill-pitfalls.md). Defer.
class ThumbnailsControllerTest < ActiveSupport::TestCase
  test "TODO migrate — fixture-hostile (see class comment for concrete blockers)" do
    skip "TODO migrate — see class-level comment above for concrete blockers"
  end
end
