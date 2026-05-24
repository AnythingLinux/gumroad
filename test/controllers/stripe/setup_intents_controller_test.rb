# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Spec was deleted in commit c9c93ee5 during the
# big RSpec->Minitest cutover; original at spec/controllers/stripe/setup_intents_controller_spec.rb.
#
# Sharpened skip-stub reason (see PR #5257 batch A):
#   VCR-only — entire spec is `describe Stripe::SetupIntentsController, :vcr` and exercises Stripe::Customer.create + ChargeProcessor.setup_future_charges! against live Stripe sandbox via VCR cassettes. No fixture path; VCR is not wired into the Minitest harness.
class Stripe::SetupIntentsControllerTest < ActiveSupport::TestCase
  test "TODO migrate — fixture-hostile (see class comment for concrete blockers)" do
    skip "TODO migrate — see class-level comment above for concrete blockers"
  end
end
