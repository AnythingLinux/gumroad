# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Service/call booking — slot selection, calendar integration, no-show handling.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class CallBookingTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Slot skipped; double-booked
  def test_call_booking_requires_slot_selection
    skip "Scaffolding"
  end

  # Production-incident class: Slot still bookable post-purchase; double-sold
  def test_call_slot_locks_to_buyer_after_purchase
    skip "Scaffolding"
  end

  # Production-incident class: Refund issued for no-show against seller policy
  def test_call_no_show_refund_policy_applied
    skip "Scaffolding"
  end

  # Production-incident class: Reschedule blocked when window allows
  def test_call_reschedule_within_window_allowed
    skip "Scaffolding"
  end
end
