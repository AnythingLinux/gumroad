# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/create_canada_monthly_sales_report_job_spec.rb (12 FactoryBot refs, 129 lines).
#
# Blocker for batch B backfill: Happy-case `describe ..., :vcr` block uses `allow(Aws::S3::Resource).to receive_message_chain(:new, :bucket).and_return(s3_bucket_double)` and `create :purchase, :with_review_response, ...` chains across product + recommended_product + offer_code + canadian seller fixtures. Requires both a real Aws::S3 stub harness (not present in the Minitest lane) and a `receive_message_chain` translation. Mocha `receive_message_chain` has no native Minitest equivalent; would need a 2-layer Struct stub per call site.
class CreateCanadaMonthlySalesReportJobTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/create_canada_monthly_sales_report_job_spec.rb — Happy-case `describe ..., :vcr` block uses `allow(Aws::S3::Resource).to receive_message_chain(:new, :bucket).and_return(s3_bucket_double)` and `create :purchase, :with_review_response, ...` chains across product + recommended_product + offer_code + canadian seller fixtures. Requires both a real Aws::S3 stub harness (not present in the Minitest l..."
  end
end
