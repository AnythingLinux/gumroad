# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/exports/sales/process_chunk_worker_spec.rb (5 FactoryBot refs, 57 lines).
#
# Blocker for batch B backfill: Builds `create(:sales_export)` + `allow(@worker).to receive(:compile_chunks).and_return(@csv_tempfile)` (an instance-method partial stub on `self.new` — no native Minitest equivalent; would need `define_singleton_method` on the constructed instance). `:sales_export` has no fixture row and the model carries a SalesExportChunk has_many association the test mutates. Out of scope.
class Exports::Sales::ProcessChunkWorkerTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/exports/sales/process_chunk_worker_spec.rb — Builds `create(:sales_export)` + `allow(@worker).to receive(:compile_chunks).and_return(@csv_tempfile)` (an instance-method partial stub on `self.new` — no native Minitest equivalent; would need `define_singleton_method` on the constructed instance). `:sales_export` has no fixture row and the model carries a SalesExportChunk has_many association..."
  end
end
