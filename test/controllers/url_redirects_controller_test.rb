# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Spec was deleted in commit c9c93ee5 during the
# big RSpec->Minitest cutover; original at spec/controllers/url_redirects_controller_spec.rb.
#
# Sharpened skip-stub reason (see PR #5257 batch A):
#   Massive (~2362 lines, 229 FB refs) — exercises every URL redirect branch: subscription, rental, license, preorder, audience, mobile redirect, transcoded video, stamped PDF, file group display, magic links. Needs ~80+ net-new fixture rows and several S3/Aws stubs. Defer.
class UrlRedirectsControllerTest < ActiveSupport::TestCase
  test "TODO migrate — fixture-hostile (see class comment for concrete blockers)" do
    skip "TODO migrate — see class-level comment above for concrete blockers"
  end
end
