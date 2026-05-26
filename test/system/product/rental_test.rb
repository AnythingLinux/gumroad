# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Time-limited rental access — start/end dates, expiration, renewal.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class RentalProductTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Access window calculated wrong; rental ends early
  def test_rental_purchase_grants_access_for_window
    skip "Scaffolding"
  end

  # Production-incident class: Expired rental still has access; revenue cannibalized
  def test_rental_expires_revokes_access
    skip "Scaffolding"
  end

  # Production-incident class: Window text wrong on receipt, support burst
  def test_rental_purchase_displays_correct_window_on_receipt
    skip "Scaffolding"
  end

  # Production-incident class: Extension creates duplicate window; access doubled
  def test_rental_can_be_extended_with_new_purchase
    skip "Scaffolding"
  end
end
