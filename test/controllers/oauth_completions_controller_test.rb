# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Spec was deleted in commit c9c93ee5 during the
# big RSpec->Minitest cutover; original at spec/controllers/oauth_completions_controller_spec.rb.
#
# Sharpened skip-stub reason (see PR #5257 batch A):
#   VCR-tagged. Exercises Stripe Connect OAuth completion flow: Stripe::Account.retrieve against real auth_uid cassettes, MerchantAccount creation across countries (Czechia/Canada), merchant_account_stripe_canada factory. Defer to dedicated Stripe-OAuth PR.
class OauthCompletionsControllerTest < ActiveSupport::TestCase
  test "TODO migrate — fixture-hostile (see class comment for concrete blockers)" do
    skip "TODO migrate — see class-level comment above for concrete blockers"
  end
end
