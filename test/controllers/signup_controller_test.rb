# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Spec was deleted in commit c9c93ee5 during the
# big RSpec->Minitest cutover; original at spec/controllers/signup_controller_spec.rb.
#
# Sharpened skip-stub reason (see PR #5257 batch A):
#   Heavy auth/recaptcha/HTTPS Devise signup flow (~503 lines, 34 FB refs). Spec uses InvitesService, OAuth, social provider stubs, FollowMailer/ActionMailer assertions, Twitter/Facebook auth, recaptcha bypass. Needs WebMock for api.pwnedpasswords, recaptcha stubs, multi-format Devise routing — defer to a focused signup-flow PR.
class SignupControllerTest < ActiveSupport::TestCase
  test "TODO migrate — fixture-hostile (see class comment for concrete blockers)" do
    skip "TODO migrate — see class-level comment above for concrete blockers"
  end
end
