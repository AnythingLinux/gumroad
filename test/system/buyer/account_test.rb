# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Buyer account creation, merging, GDPR data ops.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class BuyerAccountTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Account not linked; library empty
  def test_signup_after_purchase_links_account_to_purchase
    skip "Scaffolding"
  end

  # Production-incident class: Purchases stranded on old email
  def test_buyer_email_change_keeps_purchases
    skip "Scaffolding"
  end

  # Production-incident class: Merge loses purchases on one side
  def test_buyer_account_merge_transfers_purchases
    skip "Scaffolding"
  end

  # Production-incident class: GDPR request returns partial data; compliance gap
  def test_gdpr_export_returns_all_buyer_data
    skip "Scaffolding"
  end

  # Production-incident class: GDPR delete kills dispute evidence prematurely
  def test_gdpr_delete_with_active_disputes_retains_purchase_rows
    skip "Scaffolding"
  end
end
