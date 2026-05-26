# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# API v2 endpoint contract — purchases, products, subscribers, sales.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class ApiEndpointsTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Pagination broken; integrations break
  def test_api_v2_purchases_returns_paginated_list
    skip "Scaffolding"
  end

  # Production-incident class: Visibility filter broken; archived products leak
  def test_api_v2_products_filters_by_visible_flag
    skip "Scaffolding"
  end

  # Production-incident class: Search broken; integrations break
  def test_api_v2_subscribers_search_by_email
    skip "Scaffolding"
  end

  # Production-incident class: Column shift breaks downstream consumers
  def test_api_v2_sales_csv_export_returns_correct_columns
    skip "Scaffolding"
  end

  # Production-incident class: Create endpoint silently fails
  def test_api_v2_create_offer_code_returns_201
    skip "Scaffolding"
  end

  # Production-incident class: Multipart broken; can't upload large files
  def test_api_v2_files_multipart_upload_succeeds
    skip "Scaffolding"
  end
end
