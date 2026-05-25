require "test_helper"

# TODO: Migrate from RSpec. Charge::Disputable spec (1296 LOC, 82 create()
# refs) is `:vcr`-tagged and is the most VCR-dependent model spec in the
# suite: every dispute lifecycle path threads Stripe (or PayPal) chargeback
# webhooks through Charge::Disputable + Purchase::Disputable + creator
# notification mailers. Requires ~40 VCR cassettes ported. Out of scope for
# mechanical model backfill.
#
# Original spec: spec/models/concerns/charge/disputable_spec.rb
class Charge::DisputableTest < ActiveSupport::TestCase
  test "TODO: migrate — :vcr Stripe/PayPal chargeback lifecycle (1296 LOC)" do
    skip "Top-level :vcr; 82 create() across chargeback lifecycle (Stripe + PayPal) + mailer enqueues. Out of scope for mechanical model backfill."
  end
end
