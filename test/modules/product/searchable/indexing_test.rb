# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Backfill batch C kept skip-stub.
# Original spec: spec/modules/product/searchable/indexing_spec.rb (342 lines, 20 FB refs)
# Blockers:
#   * `#as_indexed_json` test (lines 10-52) needs `:product_with_files`,
#     `:taxonomy`, `:purchase_with_balance`, `:product_review`,
#     plus `save_files!` with S3-shaped URLs (`AWS_S3_ENDPOINT`/`S3_BUCKET`) —
#     needs MinIO file URLs (see leaf-backfill-pitfalls "S3_BASE_URL" pattern)
#     and `index_model_records(Purchase)` helper.
#   * Every describe under "Indexing the changes through callbacks" expects
#     `ProductIndexingService.to receive(:perform).with(...).and_call_original`
#     — that's a mocha partial-stub. Minitest's `Klass.stub` only fully
#     replaces, no call-through. Need to write a `expect_product_update`
#     helper that records calls in a thread-local array and asserts at end.
#   * `it "correctly indexes price_cents"` reads from `EsClient.get(...)` —
#     pure live-ES.
#   * `enqueues the job when a purchase transitions to the successful state`
#     uses `have_enqueued_sidekiq_job` matcher (RSpec-only).
# The middle blocks (#build_search_update, #build_search_property for
# offer_codes) are tractable — they call public instance methods with no ES.
# But interleaved with the ES tests in the same file, splitting risks
# half-migrate. Defer the whole file.
class ModulesProductSearchableIndexingTest < ActiveSupport::TestCase
  test "skipped: ES + mocha and_call_original partial-stub pattern + have_enqueued_sidekiq_job" do
    skip "TODO: spec/modules/product/searchable/indexing_spec.rb (20 FB refs) needs partial-stub helper + ES + sidekiq matcher port"
  end
end
