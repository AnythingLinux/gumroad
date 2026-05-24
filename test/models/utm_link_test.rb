require "test_helper"

# TODO: Migrate from RSpec. UtmLink spec (517 LOC, 54 create() refs) exercises
# a large association tree: seller + target_resource polymorphic (Link / Post /
# SellerProfile / SellerProfileSection / VariantCategory / Variant) and a
# UtmLinkVisit fixture for click-counting. shoulda-matchers shape with extensive
# `is_expected.to belong_to(...)` / `validate_presence_of`. The polymorphic
# fixture map + 6 distinct target types are out of scope for mechanical backfill.
#
# Original spec: spec/models/utm_link_spec.rb
class UtmLinkTest < ActiveSupport::TestCase
  test "TODO: migrate — polymorphic target_resource + shoulda-matchers" do
    skip "517 LOC, polymorphic target_resource across 6 model types + UtmLinkVisit + shoulda matchers. Out of scope for mechanical model backfill."
  end
end
