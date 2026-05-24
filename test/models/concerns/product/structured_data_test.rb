require "test_helper"

# TODO: Migrate from RSpec. Product::StructuredData spec (456 LOC, 17
# create() refs) is non-:vcr, non-ES, and largely fixture-doable; covers
# schema.org JSON-LD generation across digital/ebook/audiobook/subscription
# product variants + price/rating/availability matrix. Defer to a hand pass
# since it needs `product_review_stat` fixtures + image asset_previews +
# rich_content fixtures (for ebook reading metadata) + `stub(:remaining_for_sale_count)`
# and the per-context state mutation pattern doesn't map cleanly to
# fixtures.
#
# Original spec: spec/models/concerns/product/structured_data_spec.rb
class Product::StructuredDataTest < ActiveSupport::TestCase
  test "TODO: migrate Product::StructuredData schema.org JSON-LD spec" do
    skip "456 LOC schema.org JSON-LD across digital/ebook/audiobook/subscription + product_review_stat + rich_content fixtures. Defer to manual hand pass."
  end
end
