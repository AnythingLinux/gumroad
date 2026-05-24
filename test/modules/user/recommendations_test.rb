# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Backfill batch C kept skip-stub.
# Original spec: spec/modules/user/recommendations_spec.rb (64 lines, ES tag)
# Blockers:
#   * tagged `:elasticsearch_wait_for_refresh` — `recommendable?` resolves via
#     `Product::Recommendations` which reads from the live ES Link index, and
#     the relevant `Product#is_recommendable` writes only happen via
#     `enqueue_search_index!` callbacks against a live cluster.
#   * `create(:recommendable_user)` / `create(:compliant_user)` chain compiles
#     UserComplianceInfo + MerchantAccount + BankAccount + payment_address +
#     a recommendable product — 5+ net-new fixture rows per test, none of
#     which exist in test/fixtures/.
#   * tests poke `payment_address: nil` then add `:canadian_bank_account` or
#     `:merchant_account_paypal` — would also need the MerchantAccount fixture
#     graph (Stripe verification etc.).
# Covered by RSpec lane. Re-evaluate once a `compliant_user` fixture lands.
class User::RecommendationsTest < ActiveSupport::TestCase
  test "skipped: ES tag + recommendable_user/compliant_user factory chain (5+ net-new tables)" do
    skip "TODO: spec/modules/user/recommendations_spec.rb needs ES index + compliant_user fixture chain"
  end
end
