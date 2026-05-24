require "test_helper"

# TODO: Migrate from RSpec. Purchase::Blockable spec (1110 LOC, 69 create()
# refs) covers BlockedObject (email/IP/card fingerprint/charge processor
# fingerprint) interactions across purchase + buyer + chargeable factories;
# extensive Mongoid-style cross-table assertions. The full block-source matrix
# (5 block reasons × 4 attribute scopes × refund-vs-block decisioning) is out
# of scope for a mechanical pass without BlockedObject fixtures and a chargeable
# stub layer.
#
# Original spec: spec/models/concerns/purchase/blockable_spec.rb
class Purchase::BlockableTest < ActiveSupport::TestCase
  test "TODO: migrate — BlockedObject + chargeable + 69 create() refs" do
    skip "1110 LOC; BlockedObject across email/IP/card/processor + chargeable factory chain. Out of scope for mechanical model backfill."
  end
end
