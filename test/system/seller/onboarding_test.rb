# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# New seller flow — signup, Stripe Connect onboarding, first product, first sale.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class SellerOnboardingTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Signup routes wrong; seller confused
  def test_seller_signup_creates_account_routes_to_setup
    skip "Scaffolding"
  end

  # Production-incident class: OAuth callback breaks; seller can't onboard
  def test_stripe_connect_oauth_redirects_back_with_account_id
    skip "Scaffolding"
  end

  # Production-incident class: Connect Express vs Standard chosen wrong; payouts fail later
  def test_stripe_connect_country_appropriate_account_type
    skip "Scaffolding"
  end

  # Production-incident class: First product save crashes; seller abandons
  def test_first_product_creation_displays_correctly
    skip "Scaffolding"
  end

  # Production-incident class: Payout attempted without KYC; Stripe blocks
  def test_compliance_info_collected_before_first_payout
    skip "Scaffolding"
  end
end
