# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/exports/affiliate_export_worker_spec.rb (2 FactoryBot refs, 27 lines).
#
# Blocker for batch B backfill: Same shape as audience_export_worker: `create(:user)` × 2 + `expect(ContactingCreatorMailer).to receive(:affiliates_data).and_call_original`. Skill pitfall `.and_call_original` has no Minitest equivalent. Migrate alongside audience_export_worker when the `with_recorded_calls` helper lands.
class Exports::AffiliateExportWorkerTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/exports/affiliate_export_worker_spec.rb — Same shape as audience_export_worker: `create(:user)` × 2 + `expect(ContactingCreatorMailer).to receive(:affiliates_data).and_call_original`. Skill pitfall `.and_call_original` has no Minitest equivalent. Migrate alongside audience_export_worker when the `with_recorded_calls` helper lands."
  end
end
