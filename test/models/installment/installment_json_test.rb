# frozen_string_literal: true

require "test_helper"

# Skip-stub: spec/models/installment/installment_json_spec.rb
# Reason: relies on User :with_avatar trait (ActiveStorage attach + analyze of smilie.png) and
# stacks installment + product_file + url_redirect + creator_contacting_customers_email_info
# + membership_purchase + subscription fixtures. ActiveStorage attachment behavior is central
# to the assertions (creator_profile_picture_url via avatar_url), and net new fixture tables ≥5.
# Per skill ActiveStorage → SKIP policy.
class Installment::InstallmentJsonTest < ActiveSupport::TestCase
  test "skipped: ActiveStorage avatar + multi-table installment/url_redirect/subscription pipeline" do
    skip "TODO: migrate spec/models/installment/installment_json_spec.rb — ActiveStorage :with_avatar trait + multi-table fixture chain. Covered by RSpec."
  end
end
