# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Seller analytics views — sales, audience, churn, UTM links.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class SellerAnalyticsTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Chart rendering shows wrong total; seller doubts data
  def test_sales_chart_renders_correct_totals
    skip "Scaffolding"
  end

  # Production-incident class: Country filter broken; analytics misleading
  def test_audience_chart_filters_by_country
    skip "Scaffolding"
  end

  # Production-incident class: Churn formula wrong; bad decisions made
  def test_churn_chart_calculates_churn_rate
    skip "Scaffolding"
  end

  # Production-incident class: UTM dropped; attribution lost
  def test_utm_link_attribution_tracks_correct_source
    skip "Scaffolding"
  end

  # Production-incident class: Date range reset on navigation; UX broken
  def test_date_range_persists_across_navigation
    skip "Scaffolding"
  end
end
