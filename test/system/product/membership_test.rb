# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Tiered membership / subscription product — tiers, trial, plan change, cancel-end-of-period.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class MembershipProductTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Trial never converts; revenue lost
  def test_free_trial_converts_to_paid_at_window_end
    skip "Scaffolding"
  end

  # Production-incident class: Upgrade overcharges or undercharges; finance manual fix
  def test_plan_upgrade_prorates_correctly
    skip "Scaffolding"
  end

  # Production-incident class: Downgrade refunds incorrectly mid-period
  def test_plan_downgrade_takes_effect_at_period_end
    skip "Scaffolding"
  end

  # Production-incident class: Cancellation revokes immediately; buyer rage
  def test_cancel_at_period_end_retains_access_until_then
    skip "Scaffolding"
  end

  # Production-incident class: Frequency change skips a charge or double-charges
  def test_subscription_payment_option_changes_billing_frequency
    skip "Scaffolding"
  end

  # Production-incident class: Duplicate subscription created; double-bill
  def test_subscription_purchase_with_existing_subscription_replaces_or_blocks
    skip "Scaffolding"
  end

  # Production-incident class: Restart resumes old sub; billing date stale
  def test_subscription_restart_after_cancel_creates_new_subscription
    skip "Scaffolding"
  end

  # Production-incident class: Installment plan misfires on subscription
  def test_subscription_with_installment_plan_charges_installments
    skip "Scaffolding"
  end
end
