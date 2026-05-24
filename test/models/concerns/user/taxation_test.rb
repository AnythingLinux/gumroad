require "test_helper"

# TODO: Migrate from RSpec. User::Taxation spec (354 LOC, 31 create() refs)
# covers tax_id / business_vat / tax_filing_jurisdiction logic across
# multiple compliance_info revisions, payment.complete states, and uses
# `allow_any_instance_of(User)` to stub Stripe Connect / vat-id-validation
# external calls plus paper_trail (`versioning: true`). Out of scope for
# mechanical model backfill.
#
# Original spec: spec/models/concerns/user/taxation_spec.rb
class User::TaxationTest < ActiveSupport::TestCase
  test "TODO: migrate — allow_any_instance_of + paper_trail + compliance_info" do
    skip "31 create() across compliance_info revisions + allow_any_instance_of stubs + paper_trail. Out of scope for mechanical model backfill."
  end
end
