# frozen_string_literal: true

require "test_helper"

class CacheProductDataWorkerTest < ActiveSupport::TestCase
  setup do
    @product = links(:basic_user_product)
    # Short-circuit ES-backed stats so ProductCachedValue#assign_cached_values
    # doesn't reach PurchaseSearchService.search aggregations (the global
    # EsClient stub in test_helper.rb returns no aggregations).
    Link.define_method(:monthly_recurring_revenue) { 0.0 }
    Link.define_method(:total_usd_cents) { 0 }
  end

  teardown do
    [:monthly_recurring_revenue, :total_usd_cents].each do |m|
      Link.remove_method(m) if Link.instance_methods(false).include?(m)
    end
  end

  test "#perform creates new product cache data" do
    assert_difference -> { ProductCachedValue.count }, 1 do
      CacheProductDataWorker.new.perform(@product.id)
    end

    cached = @product.reload.product_cached_values.last
    assert_equal 0, cached.successful_sales_count
    assert_nil cached.remaining_for_sale_count
    assert_equal 0.0, cached.monthly_recurring_revenue
    assert_equal 0, cached.revenue_pending
    assert_equal 0, cached.total_usd_cents
  end

  test "#perform expires the current cache and creates a new cached record when data is already cached" do
    existing = @product.product_cached_values.create!
    assert_equal false, existing.reload.expired

    assert_difference -> { ProductCachedValue.count }, 1 do
      CacheProductDataWorker.new.perform(@product.id)
    end

    assert_equal true, existing.reload.expired
  end
end
