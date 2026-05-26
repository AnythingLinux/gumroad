# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Subscription lifecycle emails — renewal, payment-failed, cancel, paused.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class SubscriptionEmailTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Reminder missing; SCA exemption window missed
  def test_renewal_reminder_sent_before_recurring_charge
    skip "Scaffolding"
  end

  # Production-incident class: No payment-failed email; subscription quietly cancels
  def test_payment_failed_email_with_update_card_link
    skip "Scaffolding"
  end

  # Production-incident class: Cancel email missing; buyer chargebacks
  def test_subscription_cancelled_email_confirms_end_date
    skip "Scaffolding"
  end

  # Production-incident class: Paused email missing; buyer confused
  def test_subscription_paused_email_explains_resume
    skip "Scaffolding"
  end
end
