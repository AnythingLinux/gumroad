# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/create_vat_report_job_spec.rb (21 FactoryBot refs, 163 lines).
#
# Blocker for batch B backfill: Same `:vcr` + `Aws::S3::Resource` receive_message_chain stub shape as create_canada/india/us_state monthly sales report jobs. Builds `create(:purchase, :from_eu_buyer, was_vat_charged: true, ...)` × 6 + `:purchase, :from_uk_buyer, ...` × 2 + offer_code + zero-rated purchase fixtures. No `:from_eu_buyer` trait fixture; VAT report assertions verify quarter-bounded SUM(vat_cents) groupings that need ≥10 curated purchase rows. Out of scope alongside the other report jobs.
class CreateVatReportJobTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/create_vat_report_job_spec.rb — Same `:vcr` + `Aws::S3::Resource` receive_message_chain stub shape as create_canada/india/us_state monthly sales report jobs. Builds `create(:purchase, :from_eu_buyer, was_vat_charged: true, ...)` × 6 + `:purchase, :from_uk_buyer, ...` × 2 + offer_code + zero-rated purchase fixtures. No `:from_eu_buyer` trait fixture; VAT report assertions verif..."
  end
end
