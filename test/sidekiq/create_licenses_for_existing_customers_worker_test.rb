# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/create_licenses_for_existing_customers_worker_spec.rb (12 FactoryBot refs, 67 lines).
#
# Blocker for batch B backfill: Builds `create(:purchase)` × 3 against a shared link, then mutates `link.is_licensed = true` and `link.is_physical = true` branches; further `create(:product, is_licensed: true)` for setup. All Purchase rows go through the full charge-validation chain (skill `Purchase.create! runs heavy validations` — `fee_cents can't be blank`, daily product limit). The Purchase.new + save!(validate: false) escape hatch works for one row but each test asserts on `Purchase.licenses.count` across a fresh trio per test which the 43-row purchases fixture can't express cleanly without seller-scoping rewrites.
class CreateLicensesForExistingCustomersWorkerTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/create_licenses_for_existing_customers_worker_spec.rb — Builds `create(:purchase)` × 3 against a shared link, then mutates `link.is_licensed = true` and `link.is_physical = true` branches; further `create(:product, is_licensed: true)` for setup. All Purchase rows go through the full charge-validation chain (skill `Purchase.create! runs heavy validations` — `fee_cents can't be blank`, daily product li..."
  end
end
