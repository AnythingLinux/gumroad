# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/update_sales_related_products_infos_job_spec.rb (6 FactoryBot refs, 56 lines).
#
# Blocker for batch B backfill: Builds `create(:named_seller)` + 3 `:product` + 3 `:purchase` + asserts on `SalesRelatedProductsInfo` cross-product counts. The job hits `Purchase.successful.where(...)` joined against `purchases.product_id` pairs — needs at minimum 3 purchases of distinct products by the same buyer email + Feature.activate(:update_sales_related_products_infos). The existing 43-row purchases fixture doesn't have a buyer with 3 distinct product purchases that would produce the expected `(product_a_id, product_b_id) → count: N` rows. Would need a curated 4-row purchases fixture insertion.
class UpdateSalesRelatedProductsInfosJobTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/update_sales_related_products_infos_job_spec.rb — Builds `create(:named_seller)` + 3 `:product` + 3 `:purchase` + asserts on `SalesRelatedProductsInfo` cross-product counts. The job hits `Purchase.successful.where(...)` joined against `purchases.product_id` pairs — needs at minimum 3 purchases of distinct products by the same buyer email + Feature.activate(:update_sales_related_products_infos)...."
  end
end
