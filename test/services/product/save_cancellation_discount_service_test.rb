# frozen_string_literal: true

require "test_helper"

class Product::SaveCancellationDiscountServiceTest < ActiveSupport::TestCase
  setup do
    @product = links(:spc_membership_product)
    # spc_membership_product is a tiered membership but has no Price row in fixtures;
    # the persisted default_price_cents path needs a buy price + matching recurrence.
    @product.prices.create!(price_cents: 500, currency: "usd", recurrence: "monthly")
    # Wipe any pre-existing cancellation-discount offer codes on this product
    @product.offer_codes.is_cancellation_discount.each(&:mark_deleted!)
  end

  def service(params)
    Product::SaveCancellationDiscountService.new(@product, params)
  end

  test "creates a new fixed amount cancellation discount offer code" do
    service(discount: { type: "fixed", cents: 100 }, duration_in_billing_cycles: 3).perform

    offer_code = @product.reload.cancellation_discount_offer_code
    assert offer_code.present?
    assert_equal 100, offer_code.amount_cents
    assert_nil offer_code.amount_percentage
    assert_equal 3, offer_code.duration_in_billing_cycles
    assert_nil offer_code.code
    assert_equal [@product], offer_code.products
    assert offer_code.is_cancellation_discount?
  end

  test "fixed: when duration_in_billing_cycles is nil, creates offer code with nil duration" do
    service(discount: { type: "fixed", cents: 100 }, duration_in_billing_cycles: nil).perform
    assert_nil @product.reload.cancellation_discount_offer_code.duration_in_billing_cycles
  end

  test "fixed: when cancellation discount already exists, updates the existing offer code" do
    existing = OfferCode.create!(
      products: [@product], user_id: @product.user_id,
      is_cancellation_discount: true, amount_cents: 50, amount_percentage: nil,
      duration_in_billing_cycles: 1, code: nil,
    )

    service(discount: { type: "fixed", cents: 100 }, duration_in_billing_cycles: 3).perform

    existing.reload
    assert_equal 100, existing.amount_cents
    assert_nil existing.amount_percentage
    assert_equal 3, existing.duration_in_billing_cycles
  end

  test "creates a new percentage cancellation discount offer code" do
    service(discount: { type: "percentage", percents: 20 }, duration_in_billing_cycles: 2).perform

    offer_code = @product.reload.cancellation_discount_offer_code
    assert offer_code.present?
    assert_equal 20, offer_code.amount_percentage
    assert_nil offer_code.amount_cents
    assert_equal 2, offer_code.duration_in_billing_cycles
    assert offer_code.is_cancellation_discount?
  end

  test "percentage: when duration_in_billing_cycles is nil, creates offer code with nil duration" do
    service(discount: { type: "percentage", percents: 20 }, duration_in_billing_cycles: nil).perform
    assert_nil @product.reload.cancellation_discount_offer_code.duration_in_billing_cycles
  end

  test "percentage: when cancellation discount already exists, updates the existing offer code" do
    existing = OfferCode.create!(
      products: [@product], user_id: @product.user_id,
      is_cancellation_discount: true, amount_percentage: 10, amount_cents: nil,
      duration_in_billing_cycles: 1, code: nil,
    )

    service(discount: { type: "percentage", percents: 20 }, duration_in_billing_cycles: 2).perform

    existing.reload
    assert_equal 20, existing.amount_percentage
    assert_nil existing.amount_cents
    assert_equal 2, existing.duration_in_billing_cycles
  end

  test "when params are nil and an existing offer code exists, marks it deleted" do
    existing = OfferCode.create!(
      products: [@product], user_id: @product.user_id,
      is_cancellation_discount: true, amount_percentage: 10, amount_cents: nil,
      duration_in_billing_cycles: 1, code: nil,
    )

    service(nil).perform

    assert existing.reload.deleted?
    assert_nil @product.reload.cancellation_discount_offer_code
  end
end
