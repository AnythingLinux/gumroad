# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Backfill batch C kept skip-stub.
# Original spec: spec/modules/product/searchable/search_spec.rb (665 lines, 74 FB refs)
# Blockers:
#   * top-level `:elasticsearch_wait_for_refresh`. Every describe in this file
#     drives `Link.search` / `Link.search_options` against the live ES Link
#     index. No assertion is meaningful without create_index! + index_document
#     + a refresh wait.
#   * Pulls `:recommendable_user` and `:product, :recommendable` traits
#     (compliance + bank account + payment_address chain — see the
#     user/recommendations stub).
#   * Tests against `taxonomies`, `tags`, `:adult` flags — needs taxonomy
#     fixtures we don't have (Product::Recommendations stub also notes this).
# Defer to RSpec lane.
class ModulesProductSearchableSearchTest < ActiveSupport::TestCase
  test "skipped: 665-line ES-bound suite (Link.search/search_options end-to-end)" do
    skip "TODO: spec/modules/product/searchable/search_spec.rb (74 FB refs) needs ES cluster + recommendable_user chain + taxonomies"
  end
end
