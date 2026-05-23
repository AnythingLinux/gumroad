# frozen_string_literal: true

require "spec_helper"

describe ChargeBuyerCurrencyAmount do
  it "stores buyer currency charge totals without overwriting USD charge columns" do
    charge = build(:charge, amount_cents: 10_00, gumroad_amount_cents: 1_00)
    charge.build_buyer_currency_amount(
      buyer_currency: "eur",
      buyer_currency_amount_cents: 9_20,
      buyer_currency_gumroad_amount_cents: 92,
      buyer_currency_exchange_rate: 0.92
    )

    expect(charge.amount_cents).to eq(10_00)
    expect(charge.gumroad_amount_cents).to eq(1_00)
    expect(charge.buyer_currency_amount_cents).to eq(9_20)
    expect(charge.buyer_currency_gumroad_amount_cents).to eq(92)
  end
end
