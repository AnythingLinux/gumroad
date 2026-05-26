# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Gumroad embed (overlay + iframe widget) on external sites.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class EmbedTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Embed broken; seller's external site purchases dead
  def test_embed_overlay_loads_product_button
    skip "Scaffolding"
  end

  # Production-incident class: Modal won't open; conversion lost
  def test_embed_overlay_opens_purchase_modal
    skip "Scaffolding"
  end

  # Production-incident class: Attribution lost; revenue going to wrong account
  def test_embed_iframe_purchases_attribute_to_correct_seller
    skip "Scaffolding"
  end

  # Production-incident class: Code in URL ignored; promo broken
  def test_embed_with_offer_code_query_param_applies_discount
    skip "Scaffolding"
  end
end
