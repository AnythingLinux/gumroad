# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Heavy Stripe Connect / bank account fixture
# chain (merchant_accounts_stripe_connect, bank_accounts, tos_agreements,
# user_compliance_info, ach_account validation paths). 50 FactoryBot refs,
# ~2045 lines covering payouts settings, identity-verification, payout
# method selection across US/EU/Asia. Defer until Stripe Connect fixture
# surface is established.
# Original: spec/controllers/settings/payments_controller_spec.rb.
class Settings::PaymentsControllerTest < ActiveSupport::TestCase
  test "TODO: migrate spec/controllers/settings/payments_controller_spec.rb" do
    skip "TODO: Stripe Connect / merchant_accounts / bank_accounts fixture chain (50 FactoryBot refs)"
  end
end
