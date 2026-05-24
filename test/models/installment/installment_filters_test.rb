require "test_helper"

# TODO: Migrate from RSpec. The original spec relies on a 245-line shared
# examples file (spec/shared_examples/with_filtering_support.rb) that drives
# six audience_type variants with deep create(:installment, ...) factory
# chains. Migrating mechanically would require a parallel shared module and
# fixtures for product/variant/seller/audience/follower/affiliate installments.
# Revisit post-deadline as a single-purpose rewrite.
#
# Original spec: spec/models/installment/installment_filters_spec.rb
class InstallmentFiltersTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — shared-example driven, requires manual rewrite" do
    skip "TODO: migrate spec/models/installment/installment_filters_spec.rb (uses shared examples, 10+ FactoryBot refs)"
  end
end
