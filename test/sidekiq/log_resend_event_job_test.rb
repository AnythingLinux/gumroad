# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/log_resend_event_job_spec.rb (0 FactoryBot refs, 109 lines).
#
# Blocker for batch B backfill: EmailEvent is a Mongoid model — MongoDB is not in the Minitest CI lane. Same blocker as log_sendgrid_event_worker_test. Existing test file already has the right setup-skip; sharpened comment confirms the blocker is infrastructure (Mongo), not fixtures.
class LogResendEventJobTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/log_resend_event_job_spec.rb — EmailEvent is a Mongoid model — MongoDB is not in the Minitest CI lane. Same blocker as log_sendgrid_event_worker_test. Existing test file already has the right setup-skip; sharpened comment confirms the blocker is infrastructure (Mongo), not fixtures."
  end
end
