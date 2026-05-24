require "test_helper"

# TODO: Migrate from RSpec. WithFiltering spec (643 LOC, 87 create() refs) is
# the heaviest scopes spec in the suite: covers Installment.abandoned_cart_type
# / .with_filter_for / .with_workflow_filter / .visible_to_audience_for etc.
# across 8+ filter dimensions and the Installment+SeedProductsFilter+
# AffiliateProducts cross-product. Fixtures-only conversion would need ~12
# installment rows + workflows + variant_categories + base_variants +
# product_files. Out of scope for mechanical model backfill.
#
# Original spec: spec/models/concerns/with_filtering_spec.rb
class WithFilteringTest < ActiveSupport::TestCase
  test "TODO: migrate — 643 LOC / 87 create() refs across installment filters" do
    skip "87 create() refs across Installment + Workflow + variants + product_files filter matrix. Out of scope for mechanical model backfill."
  end
end
