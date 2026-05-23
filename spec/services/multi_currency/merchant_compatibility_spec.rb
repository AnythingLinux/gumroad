# frozen_string_literal: true

require "spec_helper"

describe MultiCurrency::MerchantCompatibility do
  describe ".supports_buyer_currency?" do
    it "allows Gumroad-managed Stripe charges in supported buyer currencies" do
      merchant_account = build_stubbed(:merchant_account, user: nil, currency: "usd")

      expect(described_class.supports_buyer_currency?(merchant_account, "eur")).to eq(true)
      expect(described_class.supports_buyer_currency?(merchant_account, "gbp")).to eq(true)
    end

    it "limits Stripe Connect accounts to their settlement currency" do
      merchant_account = build_stubbed(:merchant_account_stripe_connect, currency: "gbp", country: "GB")

      expect(described_class.supports_buyer_currency?(merchant_account, "gbp")).to eq(true)
      expect(described_class.supports_buyer_currency?(merchant_account, "eur")).to eq(false)
    end

    it "limits direct-charge India and Brazil accounts to their account currency" do
      india_account = build_stubbed(:merchant_account, currency: "inr", country: "IN")
      brazil_account = build_stubbed(:merchant_account, currency: "brl", country: "BR")

      expect(described_class.supports_buyer_currency?(india_account, "inr")).to eq(true)
      expect(described_class.supports_buyer_currency?(india_account, "eur")).to eq(false)
      expect(described_class.supports_buyer_currency?(brazil_account, "brl")).to eq(true)
      expect(described_class.supports_buyer_currency?(brazil_account, "eur")).to eq(false)
    end

    it "rejects non-Stripe merchant accounts" do
      expect(described_class.supports_buyer_currency?(build_stubbed(:merchant_account_paypal), "eur")).to eq(false)
    end
  end
end
