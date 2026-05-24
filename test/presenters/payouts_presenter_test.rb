# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during fixtures-only migration.
# Blocker: PayoutsPresenter#next_payout_period_data → UserBalanceStatsService
# → User::Stats#revenue_as_seller → PurchaseSearchService.search → ES
# aggregation accessor chain `.aggregations.price_cents_total.value`. The
# global `EsClient` fake in test_helper.rb returns plain Hashes, so the
# chain crashes with `NoMethodError: undefined method 'value' for nil`
# (gumroad-fixtures-migration skill P-5, mailer-pitfalls P-M1). Proper fix
# is a shared `test/support/user_balance_stats_stubs.rb` returning a
# Struct-shaped fetch response — out of scope for a single presenter
# migration tick (5/10 RSpec examples errored on this exact chain).
#
# Original spec: spec/presenters/payouts_presenter_spec.rb (11 FB refs)
class PayoutsPresenterTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — UserBalanceStatsService/ES aggregation stub helper required" do
    skip "TODO: migrate spec/presenters/payouts_presenter_spec.rb (11 FB refs, ES aggregation chain via UserBalanceStatsService/User::Stats)"
  end
end
