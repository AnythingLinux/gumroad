# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Spec was deleted in commit c9c93ee5 during the
# big RSpec->Minitest cutover; original at spec/controllers/concerns/two_factor_authentication_validator_spec.rb.
#
# Sharpened skip-stub reason (see PR #5257 batch A):
#   Uses RSpec anonymous controller (`controller(ApplicationController) do ... end`) + `routes.draw { ... }` block + `cookies.encrypted` stubbing + TwoFactorAuthenticationMailer enqueue matchers. Anonymous-controller pattern doesn't port to Minitest cleanly; spec is also testing concern behaviour directly. Best refactored as unit tests around `TwoFactorAuthenticationValidator` in a follow-up.
class TwoFactorAuthenticationValidatorConcernTest < ActiveSupport::TestCase
  test "TODO migrate — fixture-hostile (see class comment for concrete blockers)" do
    skip "TODO migrate — see class-level comment above for concrete blockers"
  end
end
