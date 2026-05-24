# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/compile_gumroad_daily_analytics_job_spec.rb (0 FactoryBot refs, 38 lines).
#
# Blocker for batch B backfill: Zero FB refs in source line but spec uses `create :purchase, ...` × 6 + `create :service_charge, ...` × 2 + `create :gumroad_daily_analytic, ...` and mutates `Purchase.all.map { |p| p.update!(fee_cents: ...) }`. The 43-row purchases fixture isn't scoped to the 2023-01-10..14 window the assertions check, and `Purchase.create!` runs heavy validations (skill pitfall). Plus `stub_const("CompileGumroadDailyAnalyticsJob::REFRESH_PERIOD", 5.days)` needs a `Klass.const_set` + ensure-block teardown. Out of scope — needs a dedicated time-windowed purchase fixture insertion.
class CompileGumroadDailyAnalyticsJobTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/compile_gumroad_daily_analytics_job_spec.rb — Zero FB refs in source line but spec uses `create :purchase, ...` × 6 + `create :service_charge, ...` × 2 + `create :gumroad_daily_analytic, ...` and mutates `Purchase.all.map { |p| p.update!(fee_cents: ...) }`. The 43-row purchases fixture isn't scoped to the 2023-01-10..14 window the assertions check, and `Purchase.create!` runs heavy validati..."
  end
end
