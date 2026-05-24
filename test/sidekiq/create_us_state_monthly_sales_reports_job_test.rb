# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/create_us_state_monthly_sales_reports_job_spec.rb (10 FactoryBot refs, 217 lines).
#
# Blocker for batch B backfill: Same `:vcr` + `Aws::S3::Resource` receive_message_chain stub family as create_canada/india/vat/us_states report jobs. Builds `create(:purchase, :from_us_buyer, state: "WA", ...)` × per WA-rate purchase + offer_code + refunded purchase fixtures. WA/CA/NY state-tax assertions verify SUM(price_cents) groupings keyed on state_code that need ≥6 curated purchase rows per state. Out of scope alongside the other state-report jobs.
class CreateUsStateMonthlySalesReportsJobTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/create_us_state_monthly_sales_reports_job_spec.rb — Same `:vcr` + `Aws::S3::Resource` receive_message_chain stub family as create_canada/india/vat/us_states report jobs. Builds `create(:purchase, :from_us_buyer, state: 'WA', ...)` × per WA-rate purchase + offer_code + refunded purchase fixtures. WA/CA/NY state-tax assertions verify SUM(price_cents) groupings keyed on state_code that need ≥6 curat..."
  end
end
