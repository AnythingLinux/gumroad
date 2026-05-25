require "test_helper"

# TODO: Migrate from RSpec. Product::AsJson spec (548 LOC, 44 create() refs)
# is `:vcr`-tagged and exercises the full Link#as_json projection across
# variants / base_variants / offer_codes / installment_plans / shipping_destinations
# / asset_previews / product_files / preorders, plus PurchaseSearchService /
# RecommendationEngine for some branches. Out of scope for mechanical model
# backfill.
#
# Original spec: spec/models/concerns/product/as_json_spec.rb
class Product::AsJsonTest < ActiveSupport::TestCase
  test "TODO: migrate — :vcr + Link as_json full projection" do
    skip ":vcr; Link#as_json across 8+ associations + ES recommendations. Out of scope for mechanical model backfill."
  end
end
