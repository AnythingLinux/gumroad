# frozen_string_literal: true

FactoryBot.define do
  factory :purchase_buyer_currency_amount do
    purchase
    buyer_currency { "eur" }
    buyer_currency_amount_cents { 9_20 }
    buyer_currency_exchange_rate { 0.92 }
  end
end
