# frozen_string_literal: true

require "test_helper"

class PriceTest < ActiveSupport::TestCase
  test "belongs to a link" do
    price = prices(:named_seller_product_price)
    assert_kind_of Link, price.link
  end

  test "validates presence of the link" do
    price = prices(:named_seller_product_price)
    price.link = nil
    assert_not price.valid?
    assert_includes price.errors.full_messages, "Link can't be blank"
  end

  test "non-recurring product does not require recurrence to be set" do
    product = links(:named_seller_product)
    price = product.prices.new(price_cents: 100, currency: "usd", recurrence: nil)
    assert price.valid?
  end

  test "recurring product must set recurrence" do
    product = links(:price_test_subscription_product)
    price = product.prices.new(price_cents: 100, currency: "usd", recurrence: nil)
    assert_not price.valid?
  end

  test "recurring product must be one of the permitted recurrences" do
    product = links(:price_test_subscription_product)
    BasePrice::Recurrence.all.each do |recurrence|
      price = product.prices.new(price_cents: 100, currency: "usd", recurrence:)
      assert price.valid?, "expected #{recurrence} to be valid"
    end

    invalid_price = product.prices.new(price_cents: 100, currency: "usd", recurrence: "whenever")
    assert_not invalid_price.valid?
    assert_includes invalid_price.errors.full_messages, "Invalid recurrence"
  end

  test ".alive excludes deleted prices" do
    product = links(:named_seller_product)
    live_price = prices(:named_seller_product_price)
    product.prices.create!(price_cents: 100, currency: "usd", deleted_at: Time.current)

    alive_for_product = Price.alive.where(link_id: product.id)
    assert_equal [live_price], alive_for_product.to_a
  end

  test "#alive? returns true if not deleted" do
    price = prices(:named_seller_product_price)
    assert_equal true, price.alive?
  end

  test "#alive? returns false if price is deleted" do
    price = prices(:named_seller_product_price)
    price.update!(deleted_at: Time.current)
    assert_equal false, price.alive?
  end

  test "as_json has the proper json" do
    price = prices(:price_test_subscription_product_price)
    assert_equal(
      { id: price.external_id, price_cents: 1000, recurrence: "monthly", recurrence_formatted: " a month" },
      price.as_json
    )
  end

  test "as_json includes product duration if it exists" do
    product = links(:price_test_subscription_product)
    product.update_attribute(:duration_in_months, 6)
    price = prices(:price_test_subscription_product_price)
    assert_equal(
      { id: price.external_id, price_cents: 1000, recurrence: "monthly", recurrence_formatted: " a month x 6" },
      price.as_json
    )
  end
end
