# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Preorder flow — charged at release, not at order time.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class PreorderProductTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Charged at preorder time; buyer chargebacks for non-delivery
  def test_preorder_purchase_authorizes_card_does_not_charge
    skip "Scaffolding"
  end

  # Production-incident class: Charge never triggered at release; revenue lost
  def test_preorder_charged_on_release_date
    skip "Scaffolding"
  end

  # Production-incident class: Date change silent; buyer disputes
  def test_preorder_release_date_change_notifies_buyer
    skip "Scaffolding"
  end

  # Production-incident class: Cancellation leaves authorization hanging; buyer's card credit limit consumed
  def test_preorder_cancelled_by_seller_voids_authorization
    skip "Scaffolding"
  end

  # Production-incident class: Decline silent; buyer never knows they didn't get product
  def test_preorder_card_declined_at_release_notifies_buyer
    skip "Scaffolding"
  end
end
