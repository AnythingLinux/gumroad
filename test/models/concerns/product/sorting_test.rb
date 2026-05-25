require "test_helper"

# TODO: Migrate from RSpec. Product::Sorting spec (170 LOC, 21 create() refs)
# exercises Link.sorted_by which under the hood routes through
# RecommendableProducts + PurchaseSearchService (Elasticsearch aggregations
# for sales_count / page_rank / featured). EsClient is stubbed globally in
# test_helper.rb, so ordering returns degenerate; no equivalent ES infra
# in Minitest harness. Out of scope.
#
# Original spec: spec/models/concerns/product/sorting_spec.rb
class Product::SortingTest < ActiveSupport::TestCase
  test "TODO: migrate — Elasticsearch sorted_by aggregations" do
    skip "Link.sorted_by → PurchaseSearchService ES aggregations; EsClient stubbed globally. Out of scope."
  end
end
