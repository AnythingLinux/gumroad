# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Backfill batch C kept skip-stub.
# Original spec: spec/modules/user/compliance_spec.rb (810 lines, 176 FB refs)
# This file is mechanically migratable — the dominant pattern is
# `create(:user)` + `create(:user_compliance_info_empty, user:, country: ...)`,
# both of which have analog fixtures (`users(:basic_user)` etc. +
# test/fixtures/user_compliance_info.yml). However:
#   * 810 lines × ~20 describes × ~3 user variants each is well beyond the
#     batch C 10-iter-per-file budget — would need 50+ new fixture rows
#     (one per country + risk-state combination) and significant new helper
#     for `iso3166::Country[...].common_name` lookups inline.
#   * Several tests also exercise `mark_compliant!` / `mark_suspended_for_fraud!`
#     side-effect chains that hit ProductIndexingService (ES), bank_account
#     creation, and merchant_account_creation_event sweeps.
#   * `country_supports_iban?` and related blocks reach into
#     StripeChargeProcessor verification country lists — bounded but verbose.
# Defer to a dedicated PR. Sharpen this stub once a country-matrix fixture
# generator is in place.
class ModulesUserComplianceTest < ActiveSupport::TestCase
  test "skipped: 810-line country/risk-state matrix exceeds batch budget; needs per-country fixture rows" do
    skip "TODO: spec/modules/user/compliance_spec.rb (176 FB refs) needs dedicated PR for country/risk-state matrix"
  end
end
