# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Product discovery — search, browse, recommendations, public profile.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class DiscoveryTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Search broken; discovery dead
  def test_discover_search_returns_relevant_products
    skip "Scaffolding"
  end

  # Production-incident class: Filter broken; discovery noise
  def test_discover_category_filter_narrows_results
    skip "Scaffolding"
  end

  # Production-incident class: Profile broken; seller can't share link
  def test_public_profile_lists_seller_products
    skip "Scaffolding"
  end

  # Production-incident class: Recommendations dead; conversion lost
  def test_recommendations_show_related_products
    skip "Scaffolding"
  end

  # Production-incident class: Wishlist lost; buyer leaves
  def test_wishlist_add_persists_for_logged_in_buyer
    skip "Scaffolding"
  end
end
