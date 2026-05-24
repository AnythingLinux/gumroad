require "test_helper"

# TODO: Migrate from RSpec. Original spec is `:vcr`-tagged and the factory
# chain `card_bank_account` → `credit_card` → `cc_token_chargeable` →
# `CardParamsSpecHelper.success_debit_visa` requires real Stripe tokenization
# under VCR cassettes that aren't ported to the Minitest harness. Without VCR
# infra all tests crash at credit_card creation. Out of scope for mechanical
# model backfill.
#
# Original spec: spec/models/card_bank_account_spec.rb
class CardBankAccountTest < ActiveSupport::TestCase
  test "TODO: migrate — :vcr + Stripe tokenization required" do
    skip "spec is :vcr-tagged; card_bank_account factory chains through cc_token_chargeable + Stripe tokenization. No VCR cassettes ported to Minitest. Out of scope."
  end
end
