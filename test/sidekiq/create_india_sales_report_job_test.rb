# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/create_india_sales_report_job_spec.rb (7 FactoryBot refs, 228 lines).
#
# Blocker for batch B backfill: Same `:vcr` + `Aws::S3::Resource` receive_message_chain stub family as the other monthly-sales report jobs. Builds `:purchase` × per Indian state + `:purchase, :from_india_buyer` traits + GST-aware fixture purchases. No `:from_india_buyer` trait fixture and `IndiaSalesTaxReport` rendering depends on a curated purchase-with-zip-code roster. Out of scope alongside create_canada/vat/us_state report jobs.
class CreateIndiaSalesReportJobTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/create_india_sales_report_job_spec.rb — Same `:vcr` + `Aws::S3::Resource` receive_message_chain stub family as the other monthly-sales report jobs. Builds `:purchase` × per Indian state + `:purchase, :from_india_buyer` traits + GST-aware fixture purchases. No `:from_india_buyer` trait fixture and `IndiaSalesTaxReport` rendering depends on a curated purchase-with-zip-code roster. Out o..."
  end
end
