# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched: heavy VCR/Stripe/PayPal/Braintree
# integration paths. 94 FactoryBot refs, ~2421 lines covering charge processor
# flows, SCA, multi-product orders, native PayPal, and cross-seller charges.
# Requires a fixture-based replacement for the StripePaymentMethodHelper /
# VCR cassettes which don't exist in the Minitest harness.
# Original: spec/controllers/orders_controller_spec.rb.
class OrdersControllerTest < ActiveSupport::TestCase
  test "TODO: migrate spec/controllers/orders_controller_spec.rb" do
    skip "TODO: VCR + Stripe/PayPal charge processor fixtures (94 FactoryBot refs)"
  end
end
