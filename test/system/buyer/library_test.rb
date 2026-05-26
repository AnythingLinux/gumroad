# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Buyer library — purchase history, download access, account merging.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class LibraryTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Purchases missing from library; support burst
  def test_library_shows_all_purchases
    skip "Scaffolding"
  end

  # Production-incident class: Download count not decremented; abuse
  def test_download_count_decrements_on_each_download
    skip "Scaffolding"
  end

  # Production-incident class: Refunded purchase still downloadable; revenue cannibalized
  def test_revoked_purchase_hidden_from_library
    skip "Scaffolding"
  end

  # Production-incident class: Long library crashes; UX broken
  def test_library_supports_pagination_for_heavy_buyers
    skip "Scaffolding"
  end

  # Production-incident class: Search broken; buyer can't find old purchases
  def test_library_search_finds_by_creator_or_product
    skip "Scaffolding"
  end
end
