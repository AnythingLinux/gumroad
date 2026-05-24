# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Backfill batch C kept skip-stub.
# Original spec: spec/modules/product/searchable/offer_codes_spec.rb (91 lines)
# Blockers:
#   * tagged `:elasticsearch_wait_for_refresh` and explicitly calls
#     `Link.__elasticsearch__.create_index!(force: true)` + `index_model_records(Link)`
#     in `before`. The Minitest lane has no `index_model_records` helper nor a
#     `_wait_for_refresh` test-side wait wrapper.
#   * Toggles `Feature.activate(:offer_codes_search)` — fine on its own but
#     useless without the live index above.
#   * `create(:product, :recommendable)` trait pulls the same compliant_user
#     chain as the user/recommendations spec (see that stub).
# Only the small `#build_search_property` block at the bottom (lines 70-90)
# is unit-testable without ES, but the rest dominates. Defer the whole file
# to RSpec.
class OfferCodesSearchTest < ActiveSupport::TestCase
  test "skipped: live ES create_index + recommendable trait + index_model_records helper" do
    skip "TODO: spec/modules/product/searchable/offer_codes_spec.rb needs ES cluster + recommendable_user chain"
  end
end
