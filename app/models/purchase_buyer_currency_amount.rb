# frozen_string_literal: true

class PurchaseBuyerCurrencyAmount < ApplicationRecord
  belongs_to :purchase, inverse_of: :buyer_currency_amount

  before_validation :normalize_buyer_currency

  validates :buyer_currency, presence: true, length: { is: 3 }
  validates :buyer_currency_amount_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :buyer_currency_exchange_rate, numericality: { greater_than: 0 }, allow_nil: true

  private
    def normalize_buyer_currency
      self.buyer_currency = buyer_currency.to_s.downcase.presence
    end
end
