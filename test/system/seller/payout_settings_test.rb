# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Seller payout configuration — schedule, bank account, country switch, currency.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class PayoutSettingsTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Schedule change ignored; payout timing wrong
  def test_seller_changes_payout_schedule_takes_effect_next_cycle
    skip "Scaffolding"
  end

  # Production-incident class: Invalid routing accepted; payout bounces
  def test_seller_changes_bank_account_validates_routing_number
    skip "Scaffolding"
  end

  # Production-incident class: Country switch silently corrupts existing balance
  def test_seller_country_switch_requires_new_connect_account
    skip "Scaffolding"
  end

  # Production-incident class: Payout currency changes mid-life; finance scramble
  def test_seller_payout_currency_locks_at_account_creation
    skip "Scaffolding"
  end
end
