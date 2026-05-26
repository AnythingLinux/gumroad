# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Shipped physical products — shipping address, virtual countries, shipping offer codes, physical+preorder, physical subscription.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class PhysicalProductTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Buyer checks out without address; seller can't fulfill
  def test_physical_product_requires_shipping_address
    skip "Scaffolding"
  end

  # Production-incident class: Shipping cost forgotten; seller eats shipping
  def test_shipping_cost_added_to_total
    skip "Scaffolding"
  end

  # Production-incident class: Invalid address accepted; shipment lost
  def test_shipping_address_verification_blocks_invalid
    skip "Scaffolding"
  end

  # Production-incident class: Virtual country (Vatican etc.) crashes shipping calc
  def test_shipping_to_virtual_country_handles_gracefully
    skip "Scaffolding"
  end

  # Production-incident class: Shipping discount applied to product instead
  def test_shipping_offer_code_discounts_shipping_separately
    skip "Scaffolding"
  end

  # Production-incident class: Recurring shipping not charged on renewal
  def test_physical_subscription_recurring_shipping
    skip "Scaffolding"
  end

  # Production-incident class: Preorder charged immediately, buyer chargebacks
  def test_physical_preorder_charged_at_release
    skip "Scaffolding"
  end

  # Production-incident class: Inventory race allows oversell
  def test_physical_quantity_oversell_prevention
    skip "Scaffolding"
  end
end
