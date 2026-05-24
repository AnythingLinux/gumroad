# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Spec was deleted in commit c9c93ee5 during the
# big RSpec->Minitest cutover; original at spec/controllers/settings/stripe_controller_spec.rb.
#
# Sharpened skip-stub reason (see PR #5257 batch A):
#   VCR-tagged spec. Touches merchant_account_stripe_connect / merchant_account_stripe_canada factories, ach_account factory, Feature.activate_user(:merchant_migration), Stripe webhook deauthorization flow. No fixture rows for merchant_accounts of the Stripe Connect/Canada variants. Defer.
class Settings::StripeControllerTest < ActiveSupport::TestCase
  test "TODO migrate — fixture-hostile (see class comment for concrete blockers)" do
    skip "TODO migrate — see class-level comment above for concrete blockers"
  end
end
