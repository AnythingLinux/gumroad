require "test_helper"

class Purchase::ReportableTest < ActiveSupport::TestCase
  setup do
    @purchase = purchases(:auto_invoice_enabled_purchase)
    # Sanity: ensure baseline price is 100 (used by all assertions below).
    assert_equal 100, @purchase.price_cents
  end

  test "price_cents_net_of_refunds returns the price" do
    assert_equal 100, @purchase.price_cents_net_of_refunds
  end

  test "returns 0 when purchase is chargedback" do
    @purchase.update_columns(chargeback_date: Time.current)
    assert_equal 0, @purchase.price_cents_net_of_refunds
  end

  test "returns 0 when purchase is fully refunded" do
    @purchase.update_columns(stripe_refunded: true)
    assert_equal 0, @purchase.price_cents_net_of_refunds
  end

  test "partial refund without amount returns the price" do
    @purchase.update_columns(stripe_partially_refunded: true)
    Refund.create!(purchase: @purchase, amount_cents: 0)
    assert_equal 100, @purchase.price_cents_net_of_refunds
  end

  test "partial refund with amounts returns price minus refunded amount" do
    @purchase.update_columns(stripe_partially_refunded: true)
    2.times { Refund.create!(purchase: @purchase, amount_cents: 10) }
    assert_equal 80, @purchase.price_cents_net_of_refunds
  end
end
