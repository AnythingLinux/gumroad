# frozen_string_literal: true

module MultiCurrency
  class MerchantCompatibility
    def self.supports_buyer_currency?(merchant_account, buyer_currency)
      buyer_currency = buyer_currency.to_s.downcase
      return false if buyer_currency.blank?

      supported_buyer_currencies(merchant_account).include?(buyer_currency)
    end

    def self.supported_buyer_currencies(merchant_account)
      return [] if merchant_account.blank? || !merchant_account.stripe_charge_processor?

      if merchant_account.user_id.blank?
        BuyerCurrencyService::SUPPORTED_BUYER_CURRENCIES
      else
        [merchant_account.currency.to_s.downcase.presence || Currency::USD].compact
      end
    end
  end
end
