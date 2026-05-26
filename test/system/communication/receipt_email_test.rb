# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Receipt and confirmation emails — content, localization, attachment.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class ReceiptEmailTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Receipt never sent; buyer thinks purchase failed
  def test_receipt_email_sent_after_purchase
    skip "Scaffolding"
  end

  # Production-incident class: Receipt shows wrong currency; confusion
  def test_receipt_email_contains_purchase_total_in_buyer_currency
    skip "Scaffolding"
  end

  # Production-incident class: Links missing; buyer can't access purchase
  def test_receipt_email_includes_download_links
    skip "Scaffolding"
  end

  # Production-incident class: Multi-item receipt math wrong
  def test_multi_item_receipt_lists_all_items_with_correct_totals
    skip "Scaffolding"
  end

  # Production-incident class: Invoice not attached; B2B compliance gap
  def test_invoice_attached_when_seller_invoice_enabled
    skip "Scaffolding"
  end

  # Production-incident class: Locale ignored; English email to FR buyer
  def test_receipt_email_localized_when_buyer_locale_set
    skip "Scaffolding"
  end
end
