# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Coffee/pay-what-you-want and tipping products — variable amount, minimum.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class CoffeeTipTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Minimum bypassed; under-monetized
  def test_coffee_amount_above_minimum_accepted
    skip "Scaffolding"
  end

  # Production-incident class: Minimum not enforced; abuse vector
  def test_coffee_amount_below_minimum_rejected
    skip "Scaffolding"
  end

  # Production-incident class: Tip charged separately, breaks receipt math
  def test_tip_added_to_main_purchase
    skip "Scaffolding"
  end

  # Production-incident class: Tip currency mismatch with main; FX drift
  def test_tip_charged_in_buyer_currency
    skip "Scaffolding"
  end

  # Production-incident class: $0 tip creates blank tip row; reports show ghost line items
  def test_zero_tip_skips_tip_line
    skip "Scaffolding"
  end
end
