require "test_helper"

class Upsell::SortingTest < ActiveSupport::TestCase
  setup do
    @seller = users(:bvi_test_seller)

    @product1 = Link.create!(user: @seller, name: "Product 1", price_cents: 2000, native_type: "digital")
    @product2 = Link.create!(user: @seller, name: "Product 2", price_cents: 500, native_type: "digital")

    [@product1, @product2].each do |p|
      cat = VariantCategory.create!(link: p, title: "Category")
      Variant.create!(variant_category: cat, name: "Untitled 1", price_difference_cents: 0)
      Variant.create!(variant_category: cat, name: "Untitled 2", price_difference_cents: 0)
    end

    offer_code = OfferCode.create!(user: @seller, products: [@product1], code: "sxsw1", amount_cents: 100, currency_type: @seller.currency_type)

    @upsell1 = Upsell.create!(
      seller: @seller, product: @product1,
      variant: @product1.alive_variants.second,
      name: "Upsell 1", cross_sell: true, paused: false,
      offer_code: offer_code,
      text: "x", description: "y",
    )
    @upsell2 = Upsell.create!(
      seller: @seller, product: @product2,
      name: "Upsell 2", cross_sell: false, paused: true,
      text: "x", description: "y",
    )
    upsell2_variant = UpsellVariant.create!(
      upsell: @upsell2,
      selected_variant: @product2.alive_variants.first,
      offered_variant: @product2.alive_variants.second,
    )

    # 4 upsell_purchases for upsell1 (price 2000 each), 5 for upsell2 (price 500 each)
    4.times do |i|
      purchase = Purchase.new(
        seller: @seller, link: @product1, price_cents: 2000, quantity: 1,
        total_transaction_cents: 2000, fee_cents: 0,
        purchase_state: "successful", email: "buyer-u1-#{i}@example.com",
        displayed_price_cents: 2000, displayed_price_currency_type: "usd",
        succeeded_at: Time.current,
      )
      purchase.save!(validate: false)
      UpsellPurchase.create!(upsell: @upsell1, purchase: purchase, selected_product: @product1)
    end

    5.times do |i|
      purchase = Purchase.new(
        seller: @seller, link: @product2, price_cents: 500, quantity: 1,
        total_transaction_cents: 500, fee_cents: 0,
        purchase_state: "successful", email: "buyer-u2-#{i}@example.com",
        displayed_price_cents: 500, displayed_price_currency_type: "usd",
        succeeded_at: Time.current,
      )
      purchase.save!(validate: false)
      UpsellPurchase.create!(upsell: @upsell2, purchase: purchase, selected_product: @product2, upsell_variant: upsell2_variant)
    end
  end

  test "returns upsells sorted by name" do
    order = [@upsell1, @upsell2]
    assert_equal order, @seller.upsells.sorted_by(key: "name", direction: "asc").to_a
    assert_equal order.reverse, @seller.upsells.sorted_by(key: "name", direction: "desc").to_a
  end

  test "returns upsells sorted by uses" do
    order = [@upsell1, @upsell2]
    assert_equal order, @seller.upsells.sorted_by(key: "uses", direction: "asc").to_a
    assert_equal order.reverse, @seller.upsells.sorted_by(key: "uses", direction: "desc").to_a
  end

  test "returns upsells sorted by revenue" do
    order = [@upsell2, @upsell1]
    assert_equal order, @seller.upsells.sorted_by(key: "revenue", direction: "asc").to_a
    assert_equal order.reverse, @seller.upsells.sorted_by(key: "revenue", direction: "desc").to_a
  end

  test "returns upsells sorted by status" do
    order = [@upsell1, @upsell2]
    assert_equal order, @seller.upsells.sorted_by(key: "status", direction: "asc").to_a
    assert_equal order.reverse, @seller.upsells.sorted_by(key: "status", direction: "desc").to_a
  end
end
