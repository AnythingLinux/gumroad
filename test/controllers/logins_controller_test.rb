# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Spec was deleted in commit c9c93ee5 during the
# big RSpec->Minitest cutover; original at spec/controllers/logins_controller_spec.rb.
#
# Sharpened skip-stub reason (see PR #5257 batch A):
#   Login flow with Devise + recaptcha + OAuth application chain + 2FA verification path + InvitesService merge guest cart logic + ActionMailer Devise emails. ~420 lines, 18 FB refs. Hits api.pwnedpasswords.com via Devise pwned_password validator + recaptcha endpoints. Defer to login-flow PR.
class LoginsControllerTest < ActiveSupport::TestCase
  test "TODO migrate — fixture-hostile (see class comment for concrete blockers)" do
    skip "TODO migrate — see class-level comment above for concrete blockers"
  end
end
