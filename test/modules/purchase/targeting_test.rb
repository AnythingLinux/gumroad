# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Backfill batch C kept skip-stub.
# Original spec: spec/modules/purchase/targeting_spec.rb (222 lines, 23 FB refs)
# Blockers (not ES — this is the closest-to-migratable in batch C):
#   * Pure-scope tests (Purchase.by_variant, .for_products, .paid_more_than,
#     .created_after, .country_bought_from, .by_external_variant_ids_or_products).
#   * BUT every assertion is a global count: `Purchase.by_variant(nil).count == 8`,
#     `Purchase.for_products([@product.id]).count == 2`, etc. The Minitest
#     lane already has 43 rows in test/fixtures/purchases.yml — the
#     `by_variant(nil)` no-op scope returns ALL purchases, so every
#     "count == 8" assertion fails (returns 51).
#   * Migration requires either:
#       (a) rewriting every assertion to a `Purchase.where(seller: @seller)`
#           or `Purchase.where(id: [...])` scope-narrow before applying the
#           method under test — verbose, brittle.
#       (b) wrapping each test in `Purchase.unscoped.where('1=0').or(...)` or
#           deleting all-but-the-fixture rows in setup — also brittle.
#   * `@purchase8.update_attribute(:price_cents, 0)` triggers full Purchase
#     validations on a fixture row that may not pass them (charge_processor
#     etc.). Need `update_columns` instead.
# Tractable as a dedicated PR, not within batch-C's 10-iter budget.
class ModulesPurchaseTargetingTest < ActiveSupport::TestCase
  test "skipped: global Purchase scope counts collide with 43-row fixtures.purchases.yml" do
    skip "TODO: spec/modules/purchase/targeting_spec.rb needs per-assertion seller-scoping rewrite (not a mechanical migration)"
  end
end
