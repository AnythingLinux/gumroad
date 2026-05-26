# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Seller tax configuration — VAT collection toggle, US sales tax states, EU OSS.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class TaxSettingsTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: VAT toggle ignored; under-collecting
  def test_vat_collection_toggle_starts_collecting_on_eu_sales
    skip "Scaffolding"
  end

  # Production-incident class: State toggle ignored; nexus violated
  def test_us_sales_tax_state_selection_starts_collecting
    skip "Scaffolding"
  end

  # Production-incident class: EU OSS not applied; double-reporting
  def test_eu_oss_registration_routes_eu_vat_to_oss_filing
    skip "Scaffolding"
  end

  # Production-incident class: Toggle ignored on product cards
  def test_tax_inclusive_pricing_toggle_changes_display
    skip "Scaffolding"
  end
end
