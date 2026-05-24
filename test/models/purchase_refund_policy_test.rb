# frozen_string_literal: true

require "test_helper"

class PurchaseRefundPolicyTest < ActiveSupport::TestCase
  setup do
    @purchase = purchases(:auto_invoice_enabled_purchase)
    @product = @purchase.link
    @seller = @purchase.seller
  end

  def build_purchase_for_product(product)
    p = Purchase.new(
      seller: product.user, link: product,
      price_cents: 100, total_transaction_cents: 100, fee_cents: 0,
      displayed_price_cents: 100, displayed_price_currency_type: "usd",
      purchase_state: "successful", succeeded_at: Time.current,
      email: "buyer-#{SecureRandom.hex(3)}@example.com"
    )
    p.save!(validate: false)
    p
  end

  # ---- associations ----

  test "has_one :link through :purchase" do
    assoc = PurchaseRefundPolicy.reflect_on_association(:link)
    assert_equal :has_one, assoc.macro
    assert_equal :purchase, assoc.options[:through]
  end

  test "has_one :product_refund_policy through :link" do
    assoc = PurchaseRefundPolicy.reflect_on_association(:product_refund_policy)
    assert_equal :has_one, assoc.macro
    assert_equal :link, assoc.options[:through]
  end

  # ---- validations ----

  test "validates presence of purchase and title" do
    refund_policy = PurchaseRefundPolicy.new
    refute refund_policy.valid?
    assert_equal :blank, refund_policy.errors.details[:purchase].first[:error]
    assert_equal :blank, refund_policy.errors.details[:title].first[:error]
  end

  test "max_refund_period_in_days required for records created after introduction date" do
    travel_to(PurchaseRefundPolicy::MAX_REFUND_PERIOD_IN_DAYS_INTRODUCED_ON + 1.day) do
      rp = PurchaseRefundPolicy.new(purchase: @purchase, title: "30-day money back guarantee", max_refund_period_in_days: nil)
      refute rp.valid?
      assert_equal :blank, rp.errors.details[:max_refund_period_in_days].first[:error]
    end
  end

  test "allows valid max_refund_period_in_days values after introduction date" do
    travel_to(PurchaseRefundPolicy::MAX_REFUND_PERIOD_IN_DAYS_INTRODUCED_ON + 1.day) do
      rp = PurchaseRefundPolicy.new(purchase: @purchase, title: "30-day money back guarantee", max_refund_period_in_days: 30)
      assert rp.valid?
    end
  end

  test "does not require max_refund_period_in_days for records created before introduction date" do
    travel_to(PurchaseRefundPolicy::MAX_REFUND_PERIOD_IN_DAYS_INTRODUCED_ON - 1.day) do
      # Persist so created_at gets set in the past — validation runs on the new (in-memory) record, so
      # also build a fresh new record manually with created_at set.
      rp = PurchaseRefundPolicy.new(purchase: @purchase, title: "30-day money back guarantee", max_refund_period_in_days: nil)
      rp.created_at = PurchaseRefundPolicy::MAX_REFUND_PERIOD_IN_DAYS_INTRODUCED_ON - 1.day
      assert rp.valid?
    end
  end

  test "requires max_refund_period_in_days for new (created_at nil) records" do
    rp = PurchaseRefundPolicy.new(purchase: @purchase, title: "30-day money back guarantee", max_refund_period_in_days: nil)
    refute rp.valid?
    assert_equal :blank, rp.errors.details[:max_refund_period_in_days].first[:error]
  end

  # ---- stripped_fields ----

  test "strips leading and trailing spaces for title and fine_print" do
    rp = PurchaseRefundPolicy.new(purchase: @purchase, title: "  Refund policy  ", fine_print: "  This is a product-level refund policy  ")
    rp.validate
    assert_equal "Refund policy", rp.title
    assert_equal "This is a product-level refund policy", rp.fine_print
  end

  # ---- #different_than_product_refund_policy? ----

  test "returns true when no product refund policy exists" do
    rp = @purchase.create_purchase_refund_policy!(
      title: "30-day money back guarantee",
      fine_print: "This is a purchase-level refund policy",
      max_refund_period_in_days: 30
    )
    assert rp.different_than_product_refund_policy?
  end

  test "returns false when max_refund_period_in_days matches the product refund policy" do
    purchase = build_purchase_for_product(@product)
    ProductRefundPolicy.create!(
      product: @product, seller: @seller,
      max_refund_period_in_days: 30, fine_print: "Product policy"
    )
    rp = purchase.create_purchase_refund_policy!(
      title: "Different title",
      fine_print: "Different fine print",
      max_refund_period_in_days: 30
    )
    refute rp.different_than_product_refund_policy?
  end

  test "returns true when max_refund_period_in_days differs from the product refund policy" do
    purchase = build_purchase_for_product(@product)
    ProductRefundPolicy.create!(
      product: @product, seller: @seller,
      max_refund_period_in_days: 30, fine_print: "Product policy"
    )
    rp = purchase.create_purchase_refund_policy!(
      title: "Same title",
      fine_print: "Same fine print",
      max_refund_period_in_days: 14
    )
    assert rp.different_than_product_refund_policy?
  end

  test "returns false when max_refund_period_in_days is nil and title matches product policy title" do
    purchase = build_purchase_for_product(@product)
    product_policy = ProductRefundPolicy.create!(
      product: @product, seller: @seller,
      max_refund_period_in_days: 30, fine_print: "Product policy"
    )
    # Need title from product_policy without storing max_refund_period_in_days on the purchase policy.
    rp = PurchaseRefundPolicy.new(
      purchase: purchase,
      title: product_policy.title,
      fine_print: "Different fine print",
      max_refund_period_in_days: nil
    )
    rp.created_at = PurchaseRefundPolicy::MAX_REFUND_PERIOD_IN_DAYS_INTRODUCED_ON - 1.day
    rp.save!(validate: false)
    refute rp.different_than_product_refund_policy?
  end

  test "returns true when max_refund_period_in_days is nil and title differs from product policy title" do
    purchase = build_purchase_for_product(@product)
    ProductRefundPolicy.create!(
      product: @product, seller: @seller,
      max_refund_period_in_days: 30, fine_print: "Product policy"
    )
    rp = PurchaseRefundPolicy.new(
      purchase: purchase,
      title: "Custom Refund Policy",
      fine_print: "Same fine print",
      max_refund_period_in_days: nil
    )
    rp.created_at = PurchaseRefundPolicy::MAX_REFUND_PERIOD_IN_DAYS_INTRODUCED_ON - 1.day
    rp.save!(validate: false)
    assert rp.different_than_product_refund_policy?
  end
end
