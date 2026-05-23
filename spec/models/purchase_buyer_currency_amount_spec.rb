# frozen_string_literal: true

require "spec_helper"

describe PurchaseBuyerCurrencyAmount do
  it "stores buyer currency state outside the purchases table" do
    purchase = build(:purchase)
    purchase.buyer_currency = "EUR"
    purchase.buyer_currency_amount_cents = 9_20
    purchase.buyer_currency_exchange_rate = 0.92

    expect(purchase.buyer_currency_amount).to be_a(described_class)
    expect(purchase.buyer_currency).to eq("eur")
    expect(purchase.buyer_currency_amount_cents).to eq(9_20)
    expect(purchase.buyer_currency_exchange_rate.to_s).to eq("0.92")
  end

  it "converts USD accounting amounts with the locked buyer-currency rate" do
    purchase = build(:purchase)
    purchase.buyer_currency = "eur"
    purchase.buyer_currency_exchange_rate = 0.92

    expect(BuyerCurrencyService).not_to receive(:convert_price_raw)
    expect(purchase.buyer_currency_amount_for_usd_cents(12_34)).to eq(11_35)
  end

  it "keeps zero-decimal same-currency buyer amounts as whole currency units" do
    purchase = build(:purchase, displayed_price_cents: 1_500, displayed_price_currency_type: "jpy")
    purchase.buyer_currency = "jpy"
    purchase.buyer_currency_amount_cents = purchase.displayed_price_cents
    purchase.buyer_currency_exchange_rate = 1.55

    expect(purchase.buyer_currency_amount_cents).to eq(1_500)
    expect(Money.new(purchase.buyer_currency_amount_cents, purchase.buyer_currency).format(no_cents_if_whole: true)).to eq("¥1,500")
  end

  it "converts seller balance issued net cents into the issued currency" do
    purchase = build(:purchase)
    purchase.buyer_currency = "eur"
    purchase.buyer_currency_exchange_rate = 0.92
    flow_of_funds = FlowOfFunds.build_simple_flow_of_funds("eur", 9_20)

    expect(purchase.send(:issued_net_cents_for_flow_of_funds, 5_00, flow_of_funds)).to eq(4_60)
  end
end
