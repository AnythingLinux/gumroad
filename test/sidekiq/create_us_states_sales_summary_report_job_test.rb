# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/create_us_states_sales_summary_report_job_spec.rb (11 FactoryBot refs, 130 lines).
#
# Blocker for batch B backfill: Mirror of create_canada_monthly_sales_report_job_spec: `:vcr` happy-case with `Aws::S3::Resource` receive_message_chain stub, plus `AccountingMailer.us_states_sales_summary_report_failed` retries_exhausted callback test using `double("mailer")` (no native Minitest equivalent — needs P-M9b stash-and-restore on the mailer class method). Out of scope alongside the other state-sales-report jobs.
class CreateUsStatesSalesSummaryReportJobTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/create_us_states_sales_summary_report_job_spec.rb — Mirror of create_canada_monthly_sales_report_job_spec: `:vcr` happy-case with `Aws::S3::Resource` receive_message_chain stub, plus `AccountingMailer.us_states_sales_summary_report_failed` retries_exhausted callback test using `double('mailer')` (no native Minitest equivalent — needs P-M9b stash-and-restore on the mailer class method). Out of sco..."
  end
end
