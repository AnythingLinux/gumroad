# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/exports/audience_export_worker_spec.rb (2 FactoryBot refs, 29 lines).
#
# Blocker for batch B backfill: Builds `create(:user)` × 2 (seller + recipient) and uses `expect(ContactingCreatorMailer).to receive(:subscribers_data).and_call_original`. The `.and_call_original` partial stub has no native Minitest equivalent — skill pitfall `Mocha .and_call_original partial stubs do NOT port`. Would need the `with_recorded_calls` helper, plus the `subscribers_data` mailer action ends up generating a real CSV which depends on follower/affiliate query plumbing not asserted on in the file.
class Exports::AudienceExportWorkerTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/exports/audience_export_worker_spec.rb — Builds `create(:user)` × 2 (seller + recipient) and uses `expect(ContactingCreatorMailer).to receive(:subscribers_data).and_call_original`. The `.and_call_original` partial stub has no native Minitest equivalent — skill pitfall `Mocha .and_call_original partial stubs do NOT port`. Would need the `with_recorded_calls` helper, plus the `subscriber..."
  end
end
