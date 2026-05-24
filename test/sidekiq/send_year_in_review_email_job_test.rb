# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/send_year_in_review_email_job_spec.rb (3 FactoryBot refs, 301 lines).
#
# Blocker for batch B backfill: Although only 3 FB refs at the top, every `context` builds `:user_with_compliance_info, :with_annual_report, ...` via `include PaymentsHelper, ProductPageViewHelpers` mixins. PaymentsHelper exposes `create_payment_for(...)` that cascades through bank_account + merchant_account + payments rows. `:with_annual_report` trait synthesizes a UserComplianceInfo annual_report_url ActiveStorage attachment. Needs both the ActiveStorage disk-service shim (skill `leaf-backfill-pitfalls`) AND PaymentsHelper fixture port. Out of scope.
class SendYearInReviewEmailJobTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/send_year_in_review_email_job_spec.rb — Although only 3 FB refs at the top, every `context` builds `:user_with_compliance_info, :with_annual_report, ...` via `include PaymentsHelper, ProductPageViewHelpers` mixins. PaymentsHelper exposes `create_payment_for(...)` that cascades through bank_account + merchant_account + payments rows. `:with_annual_report` trait synthesizes a UserCompli..."
  end
end
