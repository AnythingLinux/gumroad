# frozen_string_literal: true

require "test_helper"

class Purchase::PaypalTest < ActiveSupport::TestCase
  def build_purchase(charge_processor_id: nil, card_visual: "user@example.com")
    Purchase.new(charge_processor_id: charge_processor_id, card_visual: card_visual)
  end

  test "#paypal_email returns card_visual when purchase is PayPal" do
    purchase = build_purchase(charge_processor_id: PaypalChargeProcessor.charge_processor_id)
    assert_equal "user@example.com", purchase.paypal_email
  end

  test "#paypal_email returns nil when charge_processor_id is not PayPal" do
    purchase = build_purchase(charge_processor_id: StripeChargeProcessor.charge_processor_id)
    assert_nil purchase.paypal_email
  end

  test "#paypal_email returns nil when card_visual is blank" do
    purchase = build_purchase(charge_processor_id: PaypalChargeProcessor.charge_processor_id, card_visual: nil)
    assert_nil purchase.paypal_email
  end
end
