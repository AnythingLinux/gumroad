# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/log_sendgrid_event_worker_spec.rb (0 FactoryBot refs, 34 lines).
#
# Blocker for batch B backfill: EmailEvent is a Mongoid model — MongoDB is not in the Minitest CI lane. `EmailEvent.log_send_events` / `.find_by(email_digest:)` require a live Mongoid connection. The pre-existing skip on setup correctly documents this; sharpening confirms the blocker is infrastructure (Mongo), not fixtures. Mirror of log_resend_event_job_test.
class LogSendgridEventWorkerTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/log_sendgrid_event_worker_spec.rb — EmailEvent is a Mongoid model — MongoDB is not in the Minitest CI lane. `EmailEvent.log_send_events` / `.find_by(email_digest:)` require a live Mongoid connection. The pre-existing skip on setup correctly documents this; sharpening confirms the blocker is infrastructure (Mongo), not fixtures. Mirror of log_resend_event_job_test."
  end
end
