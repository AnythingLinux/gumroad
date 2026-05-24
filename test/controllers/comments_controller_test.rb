# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Spec was deleted in commit c9c93ee5 during the
# big RSpec->Minitest cutover; original at spec/controllers/comments_controller_spec.rb.
#
# Sharpened skip-stub reason (see PR #5257 batch A):
#   Very large (~688 lines, 108 FB refs). Tests audience/comments tree against complex purchase+post fixtures, partial render assertions, audience role logic. Owner-side mutation tests need pre-installed pundit shared examples. Out of scope; revisit after fixture roster grows.
class CommentsControllerTest < ActiveSupport::TestCase
  test "TODO migrate — fixture-hostile (see class comment for concrete blockers)" do
    skip "TODO migrate — see class-level comment above for concrete blockers"
  end
end
