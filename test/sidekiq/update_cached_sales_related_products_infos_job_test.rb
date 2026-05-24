# frozen_string_literal: true

require "test_helper"

class UpdateCachedSalesRelatedProductsInfosJobTest < ActiveSupport::TestCase
  setup do
    @product = links(:basic_user_product)
    @product_2 = links(:named_seller_product)
    @product_3 = links(:another_seller_product)
    CachedSalesRelatedProductsInfo.where(product_id: [@product.id, @product_2.id, @product_3.id]).delete_all
    SalesRelatedProductsInfo.where(smaller_product_id: [@product.id, @product_2.id, @product_3.id])
                            .or(SalesRelatedProductsInfo.where(larger_product_id: [@product.id, @product_2.id, @product_3.id]))
                            .delete_all
    # Seed SRPI rows directly (avoids heavy purchase fixture chain)
    pair = ->(a, b, count) {
      smaller, larger = [a, b].sort
      SalesRelatedProductsInfo.create!(smaller_product_id: smaller, larger_product_id: larger, sales_count: count)
    }
    pair.call(@product.id, @product_2.id, 2)
    pair.call(@product.id, @product_3.id, 1)
    pair.call(@product_2.id, @product_3.id, 1)
  end

  test "creates a cached record for the product's related products counts" do
    assert_difference "CachedSalesRelatedProductsInfo.count", 1 do
      UpdateCachedSalesRelatedProductsInfosJob.new.perform(@product.id)
    end
    cache = CachedSalesRelatedProductsInfo.find_by!(product: @product)
    assert_equal({ @product_2.id => 2, @product_3.id => 1 }, cache.normalized_counts)
  end

  test "updates an existing cached record when counts change" do
    UpdateCachedSalesRelatedProductsInfosJob.new.perform(@product.id)
    # Bump SRPI count for (product, product_3) to 2 to mirror the spec's second-half assertion.
    smaller, larger = [@product.id, @product_3.id].sort
    SalesRelatedProductsInfo.where(smaller_product_id: smaller, larger_product_id: larger).update_all(sales_count: 2)

    assert_no_difference "CachedSalesRelatedProductsInfo.count" do
      UpdateCachedSalesRelatedProductsInfosJob.new.perform(@product.id)
    end
    cache = CachedSalesRelatedProductsInfo.find_by!(product: @product)
    assert_equal({ @product_2.id => 2, @product_3.id => 2 }, cache.normalized_counts)
  end
end
