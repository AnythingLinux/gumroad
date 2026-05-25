require "test_helper"

# TODO: Migrate from RSpec. Original spec has 32 create() refs spanning
# active_follower / deleted_follower / unconfirmed_follower traits, workflows
# + installments + installment_rules + AudienceMember callbacks (purchases),
# plus FollowerMailer enqueue assertions and the "Deletable concern" shared
# example. The AudienceMember + Workflow fanout would need ~6 new fixture
# tables wired up. Out of scope for the mechanical model backfill.
#
# Original spec: spec/models/follower_spec.rb
class FollowerTest < ActiveSupport::TestCase
  test "TODO: migrate — Workflow + Installment + AudienceMember + Mailer fanout" do
    skip "Requires active_follower/deleted_follower traits + workflows + installments + AudienceMember + FollowerMailer enqueue (32 create() refs across 6+ tables). Out of scope for mechanical model backfill."
  end
end
