# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Spec was deleted in commit c9c93ee5 during the
# big RSpec->Minitest cutover; original at spec/controllers/bundles/product_controller_spec.rb.
#
# Sharpened skip-stub reason (see PR #5257 batch A):
#   Requires :asset_preview factory chain (ActiveStorage attached/upload through MinIO+S3 — same Makara blacklisting trap as ActiveStorage attachment recipe). Also pulls refund_policies, ProductRefundPolicy, custom_attributes, suggested_price, and `index_model_records(Purchase)`. Net-new fixture rows + S3 disk-service shim required.
class Bundles::ProductControllerTest < ActiveSupport::TestCase
  test "TODO migrate — fixture-hostile (see class comment for concrete blockers)" do
    skip "TODO migrate — see class-level comment above for concrete blockers"
  end
end
