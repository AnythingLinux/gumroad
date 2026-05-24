# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/generate_subscribe_preview_job_spec.rb (1 FactoryBot refs, 44 lines).
#
# Blocker for batch B backfill: Reads `File.binread("#{Rails.root}/spec/support/fixtures/subscribe_preview.png")` — that fixture binary lives under spec/support/ which is gone (deleted in the bulk RSpec→Minitest migration). Also `allow(SubscribePreviewGeneratorService).to receive(:generate_pngs).and_return(subscribe_preview)` (partial stub) and asserts on `user.subscribe_preview` ActiveStorage attachment. Needs the disk-service shim (skill `leaf-backfill-pitfalls`) PLUS migrating the PNG binary into test/fixtures/files/. Out of scope for batch B.
class GenerateSubscribePreviewJobTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/generate_subscribe_preview_job_spec.rb — Reads `File.binread('#{Rails.root}/spec/support/fixtures/subscribe_preview.png')` — that fixture binary lives under spec/support/ which is gone (deleted in the bulk RSpec→Minitest migration). Also `allow(SubscribePreviewGeneratorService).to receive(:generate_pngs).and_return(subscribe_preview)` (partial stub) and asserts on `user.subscribe_previ..."
  end
end
