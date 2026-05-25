require "test_helper"

# TODO: Migrate from RSpec. Purchase::Searchable spec (578 LOC, 55 create()
# refs) exercises ElasticsearchIndexerWorker + as_indexed_json + .build_search
# query construction; uses `:sidekiq_inline` + `:elasticsearch_wait_for_refresh`
# tags. EsClient is stubbed globally in test_helper.rb so ES round-trips return
# no-ops; no equivalent infra in the Minitest harness. Out of scope.
#
# Original spec: spec/models/concerns/purchase/searchable_spec.rb
class Purchase::SearchableTest < ActiveSupport::TestCase
  test "TODO: migrate — Elasticsearch indexing/search" do
    skip "Requires Elasticsearch (sidekiq_inline + elasticsearch_wait_for_refresh + EsClient real round-trips). EsClient stubbed globally in test_helper. Out of scope."
  end
end
