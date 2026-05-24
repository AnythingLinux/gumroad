# frozen_string_literal: true

require "test_helper"

# Skip-stub: spec/models/concerns/user/affiliated_products_spec.rb
# Reason: 21 FB references including :purchase_in_progress, :chargeable, :direct_affiliate, driving the full
# purchase.process! + update_balance_and_mark_successful! + refund_and_save! pipeline (VCR/Stripe + Balance
# state machine). Threshold + infra cost too high for fixtures. Per skip-batch policy.
class User::AffiliatedProductsTest < ActiveSupport::TestCase
  test "skipped: VCR + purchase pipeline + chargeable factory chain" do
    skip "TODO: migrate spec/models/concerns/user/affiliated_products_spec.rb — purchase_in_progress + chargeable + direct_affiliate VCR pipeline. Covered by RSpec."
  end
end
