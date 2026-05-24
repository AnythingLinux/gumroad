require "test_helper"

# TODO: Migrate from RSpec. Purchase::ChargeEventsHandler spec (354 LOC, 21
# create() refs) is `:vcr`-tagged and feeds real ChargeEvent payloads from
# Stripe webhooks through StripeChargeProcessor + handle_charge_event flow.
# Requires VCR cassettes for dispute / refund / settled / settled_failed
# transitions. Out of scope for mechanical model backfill.
#
# Original spec: spec/models/concerns/purchase/charge_events_handler_spec.rb
class Purchase::ChargeEventsHandlerTest < ActiveSupport::TestCase
  test "TODO: migrate — :vcr Stripe ChargeEvent handlers" do
    skip ":vcr; Stripe ChargeEvent dispute/refund/settled webhooks. Out of scope for mechanical model backfill."
  end
end
