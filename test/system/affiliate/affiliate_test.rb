# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Affiliate commission flows — link tracking, commission split, payout timing, self-purchase fraud prevention.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class AffiliateTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Affiliate link drops attribution; affiliate unpaid
  def test_affiliate_link_attributes_sale_to_affiliate
    skip "Scaffolding"
  end

  # Production-incident class: Commission calc wrong; over/under-pays affiliate
  def test_affiliate_commission_split_at_charge_time
    skip "Scaffolding"
  end

  # Production-incident class: Affiliate buys own link; commission paid (fraud)
  def test_affiliate_self_purchase_blocked_or_no_commission
    skip "Scaffolding"
  end

  # Production-incident class: Affiliate paid before refund window; clawback
  def test_affiliate_payout_held_until_refund_window_passes
    skip "Scaffolding"
  end

  # Production-incident class: Code+link combo over-discounts
  def test_affiliate_link_with_offer_code_combines_correctly
    skip "Scaffolding"
  end

  # Production-incident class: Affiliate signup broken; partner can't join
  def test_affiliate_signup_form_creates_account
    skip "Scaffolding"
  end
end
