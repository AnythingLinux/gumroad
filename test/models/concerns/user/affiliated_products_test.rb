require "test_helper"

# TODO: Migrate from RSpec. Original spec is `:vcr`-tagged and requires
# `purchase.process!` + `update_balance_and_mark_successful!` (Stripe), plus
# 8 products, 3 direct_affiliates, and 7 purchases — out of scope for the
# mechanical model backfill without VCR cassettes ported to Minitest.
#
# Original spec: spec/models/concerns/user/affiliated_products_spec.rb
class User::AffiliatedProductsTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — requires VCR + Stripe processing chain" do
    skip "Requires :vcr cassettes for purchase.process!/update_balance_and_mark_successful! (Stripe). 21 create() refs across affiliates, products, purchases. Out of scope for mechanical model backfill."
  end
end
