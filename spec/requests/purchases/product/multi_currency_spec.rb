# frozen_string_literal: true

require "spec_helper"

describe "Multi-currency checkout", type: :system, js: true do
  let(:seller) do
    User.create!(
      name: "Seller",
      username: "seller#{SecureRandom.hex(4)}",
      email: "seller-#{SecureRandom.hex(4)}@example.com",
      password: "-42Q_.c_3628Ca!mW-xTJ8v*",
      confirmed_at: Time.current,
      user_risk_state: "not_reviewed",
      payment_address: "seller-payment-#{SecureRandom.hex(4)}@example.com",
      current_sign_in_ip: "127.0.0.1",
      last_sign_in_ip: "127.0.0.1",
      account_created_ip: "127.0.0.1",
      pre_signup_affiliate_request_processed: true,
      skip_enabling_two_factor_authentication: true
    )
  end
  let!(:product) do
    Link.create!(
      user: seller,
      price_cents: 10000,
      name: "Test Product",
      description: "Test product description",
      display_product_reviews: true
    )
  end

  before do
    MerchantAccount.create!(
      user: seller,
      charge_processor_id: StripeChargeProcessor.charge_processor_id,
      charge_processor_merchant_id: SecureRandom.hex(12),
      charge_processor_alive_at: Time.current
    )
  end

  describe "product page pricing" do
    context "when multi_currency_checkout flag is enabled" do
      before { Flipper.enable(:multi_currency_checkout) }
      after { Flipper.disable(:multi_currency_checkout) }

      it "shows local currency price for non-US buyer" do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return("2.47.255.255") # Italy → EUR
        stub_currency_conversion("usd", "eur", rate: 0.92)

        visit short_link_path(product.unique_permalink)
        expect(page).to have_text("€")
        expect(page).not_to have_text("$100")
      end

      it "shows USD price for US buyers" do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return("8.8.8.8") # US → USD
        visit short_link_path(product.unique_permalink)
        expect(page).to have_text("$100")
      end

      it "shows USD price for buyers in unmapped countries" do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return("171.96.70.108") # Thailand → not mapped
        visit short_link_path(product.unique_permalink)
        expect(page).to have_text("$100")
      end
    end

    context "when multi_currency_checkout flag is disabled" do
      it "shows USD price regardless of buyer location" do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return("2.47.255.255") # Italy
        visit short_link_path(product.unique_permalink)
        expect(page).to have_text("$100")
      end
    end
  end

  describe "checkout page" do
    context "when multi_currency_checkout flag is enabled" do
      before { Flipper.enable(:multi_currency_checkout) }
      after { Flipper.disable(:multi_currency_checkout) }

      it "shows local currency on checkout for non-US buyer" do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return("81.2.69.142") # UK → GBP
        stub_currency_conversion("usd", "gbp", rate: 0.79)

        visit short_link_path(product.unique_permalink)
        add_to_cart(product)
        visit checkout_path
        expect(page).to have_text("£")
      end
    end

    context "when multi_currency_checkout flag is disabled" do
      it "shows USD on checkout regardless of buyer location" do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return("81.2.69.142") # UK
        visit short_link_path(product.unique_permalink)
        add_to_cart(product)
        visit checkout_path
        expect(page).to have_text("$100")
      end
    end
  end

  private
    def stub_currency_conversion(from, to, rate:)
      allow_any_instance_of(BuyerCurrencyService).to receive(:get_usd_cents) { |_, _, cents| cents }
      allow_any_instance_of(BuyerCurrencyService).to receive(:usd_cents_to_currency) { |_, _, cents| (cents * rate).round }
      allow(BuyerCurrencyService).to receive(:exchange_rate).with(from_currency: from, to_currency: to).and_return(rate)
    end
end
