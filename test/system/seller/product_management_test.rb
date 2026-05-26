# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Seller product CRUD — create, edit, archive, publish, variants.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class ProductManagementTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Create flow broken; seller can't publish
  def test_product_create_with_minimum_fields_succeeds
    skip "Scaffolding"
  end

  # Production-incident class: Edit invalidates URLs; buyers locked out
  def test_product_edit_preserves_existing_purchases
    skip "Scaffolding"
  end

  # Production-incident class: Archive cuts library access; buyers locked out
  def test_product_archive_hides_from_discovery_keeps_library_access
    skip "Scaffolding"
  end

  # Production-incident class: Publish does nothing; seller waiting
  def test_product_publish_makes_purchasable
    skip "Scaffolding"
  end

  # Production-incident class: New variant breaks old purchases; rollback needed
  def test_variant_add_works_with_existing_purchases
    skip "Scaffolding"
  end

  # Production-incident class: Custom domain breaks; product 404s
  def test_custom_domain_links_to_product
    skip "Scaffolding"
  end
end
