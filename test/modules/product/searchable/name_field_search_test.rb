# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Backfill batch C kept skip-stub.
# Original spec: spec/modules/product/searchable/name_field_search_spec.rb (96 lines)
# Blockers:
#   * tagged `:elasticsearch_wait_for_refresh` and explicitly calls
#     `Link.__elasticsearch__.create_index!(force: true)` +
#     `Link.__elasticsearch__.search(args).records` for every assertion.
#     There is no path to assert on `partial_search_options` matching without
#     a live ES cluster — it builds an ES `query_string` query and ships it.
#   * Uses `shared_examples_for "includes product"` / "not includes product"
#     RSpec construct with `it_behaves_like` — no Minitest equivalent without
#     a custom helper module.
#   * `:sidekiq_inline` block also relies on `:product, :recommendable` trait
#     (recommendable_user chain).
# Defer to RSpec lane.
class NameFieldSearchTest < ActiveSupport::TestCase
  test "skipped: live ES + partial_search_options + shared_examples DSL" do
    skip "TODO: spec/modules/product/searchable/name_field_search_spec.rb needs ES cluster (partial_search_options is pure-ES)"
  end
end
