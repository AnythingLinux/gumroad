# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Spec was deleted in commit c9c93ee5 during the
# big RSpec->Minitest cutover; original at spec/controllers/settings/profile_controller_spec.rb.
#
# Sharpened skip-stub reason (see PR #5257 batch A):
#   VCR-tagged (`:vcr`) + ActiveStorage avatar attach/purge against MinIO (Aws::S3::Errors::AccessDenied) + GenerateSubscribePreviewJob enqueue assertions + SellerProfileSection factory + concurrent attachment race-condition stubs. Requires disk-service shim + S3 mocks. Defer.
class Settings::ProfileControllerTest < ActiveSupport::TestCase
  test "TODO migrate — fixture-hostile (see class comment for concrete blockers)" do
    skip "TODO migrate — see class-level comment above for concrete blockers"
  end
end
