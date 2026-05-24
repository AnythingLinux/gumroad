require "test_helper"

# TODO: Migrate from RSpec. AttributeBlockable spec (816 LOC, 49 create()
# refs) exercises BlockedObject + User/Purchase attribute blocking across
# email, IP, card fingerprint, browser fingerprint, charge_processor
# fingerprint and the buyer / merchant_account dimensions. Each block source
# needs its own fixture wiring + chargeable factory chain. Out of scope for
# mechanical model backfill — same shape as Purchase::Blockable.
#
# Original spec: spec/models/concerns/attribute_blockable_spec.rb
class AttributeBlockableTest < ActiveSupport::TestCase
  test "TODO: migrate — BlockedObject across 5 attribute scopes" do
    skip "49 create() refs across BlockedObject email/IP/card/browser/processor scopes + chargeable factory. Out of scope for mechanical model backfill."
  end
end
