# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Seller-facing notifications — new sale, dispute, EFW, low balance, payout sent.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class SellerNotificationTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Sale notification missing; seller blind to activity
  def test_new_sale_email_delivered_to_seller
    skip "Scaffolding"
  end

  # Production-incident class: Dispute email missed; default loss
  def test_dispute_created_email_with_response_deadline
    skip "Scaffolding"
  end

  # Production-incident class: EFW email missing; chargeback follows
  def test_efw_email_with_recommended_action
    skip "Scaffolding"
  end

  # Production-incident class: Payout email missing; seller can't reconcile
  def test_payout_sent_email_with_amount_and_destination
    skip "Scaffolding"
  end
end
