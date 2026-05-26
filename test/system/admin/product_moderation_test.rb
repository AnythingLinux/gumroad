# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Admin product actions — flag, takedown, mass refund.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class AdminProductModerationTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Flagged product still discoverable
  def test_admin_flag_product_hides_from_discovery
    skip "Scaffolding"
  end

  # Production-incident class: Takedown leaves buyers with access to fraud product
  def test_admin_takedown_product_revokes_buyer_access
    skip "Scaffolding"
  end

  # Production-incident class: Mass refund partial; some buyers stranded
  def test_admin_mass_refund_for_fraud_product_processes_all_purchases
    skip "Scaffolding"
  end
end
