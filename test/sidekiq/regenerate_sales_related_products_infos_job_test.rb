# frozen_string_literal: true

require "test_helper"

class RegenerateSalesRelatedProductsInfosJobTest < ActiveSupport::TestCase
  setup do
    @seller = users(:named_seller)
    @sample_product = links(:named_seller_product)
    @product1 = links(:basic_user_product)
    @product2 = links(:another_seller_product)
    @product3 = links(:named_seller_archived_product)

    # Clear any existing SRPI rows referencing these products
    ids = [@sample_product.id, @product1.id, @product2.id, @product3.id]
    SalesRelatedProductsInfo.where(smaller_product_id: ids).or(SalesRelatedProductsInfo.where(larger_product_id: ids)).delete_all

    # Seed purchases: 3 emails buy sample_product, 3 buy product1, 2 buy product2, 1 (customer0) buys product3.
    [@sample_product, @product1].each do |product|
      3.times do |i|
        seed_purchase(product, "customer#{i}@example.com")
      end
    end
    2.times do |i|
      seed_purchase(@product2, "customer#{i}@example.com")
    end
    seed_purchase(@product3, "customer0@example.com")
  end

  def seed_purchase(product, email)
    Purchase.connection.insert(<<~SQL.squish)
      INSERT INTO purchases (seller_id, link_id, email, price_cents, total_transaction_cents,
        displayed_price_cents, displayed_price_currency_type, purchase_state, succeeded_at,
        fee_cents, created_at, updated_at)
      VALUES (#{product.user_id}, #{product.id}, '#{email}', 100, 100, 100, 'usd',
        'successful', NOW(), 0, NOW(), NOW())
    SQL
  end

  test "creates SalesRelatedProductsInfo records for the product" do
    assert_difference "SalesRelatedProductsInfo.count", 3 do
      RegenerateSalesRelatedProductsInfosJob.new.perform(@sample_product.id)
    end
    assert_equal 3, SalesRelatedProductsInfo.find_or_create_info(@sample_product.id, @product1.id).sales_count
    assert_equal 2, SalesRelatedProductsInfo.find_or_create_info(@sample_product.id, @product2.id).sales_count
    assert_equal 1, SalesRelatedProductsInfo.find_or_create_info(@sample_product.id, @product3.id).sales_count

    SalesRelatedProductsInfo.find_or_create_info(@sample_product.id, @product1.id).delete
    SalesRelatedProductsInfo.find_or_create_info(@sample_product.id, @product2.id).update_column(:sales_count, 0)

    assert_difference "SalesRelatedProductsInfo.count", 1 do
      RegenerateSalesRelatedProductsInfosJob.new.perform(@sample_product.id)
    end
    assert_equal 3, SalesRelatedProductsInfo.find_or_create_info(@sample_product.id, @product1.id).sales_count
    assert_equal 2, SalesRelatedProductsInfo.find_or_create_info(@sample_product.id, @product2.id).sales_count
    assert_equal 1, SalesRelatedProductsInfo.find_or_create_info(@sample_product.id, @product3.id).sales_count
  end
end
