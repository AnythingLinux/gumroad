# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Seller dashboard — sales analytics, recent purchases, payouts due.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class SellerDashboardTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Sales feed broken; seller blind to activity
  def test_dashboard_shows_recent_sales
    skip "Scaffolding"
  end

  # Production-incident class: Balance display lags; seller doesn't know
  def test_dashboard_shows_balance_and_next_payout_date
    skip "Scaffolding"
  end

  # Production-incident class: Link broken; seller can't reach payout page
  def test_dashboard_links_to_payouts_page
    skip "Scaffolding"
  end

  # Production-incident class: Date filter broken; analytics wrong
  def test_dashboard_filters_by_date_range
    skip "Scaffolding"
  end

  # Production-incident class: Mobile dashboard broken; seller can't manage on phone
  def test_dashboard_mobile_layout_works
    skip "Scaffolding"
  end
end
