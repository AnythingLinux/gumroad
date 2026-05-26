# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Seller-configured webhook delivery — sale notification, refund, dispute, subscription event.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class OutboundWebhooksTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Webhook silently fails; seller's CRM out of sync
  def test_sale_event_delivers_to_seller_webhook
    skip "Scaffolding"
  end

  # Production-incident class: Signature wrong; consumer rejects
  def test_refund_event_delivers_signed_payload
    skip "Scaffolding"
  end

  # Production-incident class: No retry on transient failure; data lost
  def test_webhook_failure_retries_with_backoff
    skip "Scaffolding"
  end

  # Production-incident class: Failure silent; seller doesn't know
  def test_webhook_delivery_failure_alerts_seller
    skip "Scaffolding"
  end

  # Production-incident class: State transition omitted; consumer confused
  def test_subscription_event_delivers_correct_state_transition
    skip "Scaffolding"
  end

  # Production-incident class: Schema drift breaks Zapier integration
  def test_zapier_event_format_matches_schema
    skip "Scaffolding"
  end
end
