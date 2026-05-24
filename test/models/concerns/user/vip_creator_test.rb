# frozen_string_literal: true

require "test_helper"

class User::VipCreatorTest < ActiveSupport::TestCase
  test "#vip_creator? returns true when gross completed payouts exceed the threshold" do
    user = users(:vip_above_threshold_user)
    assert user.vip_creator?
  end

  test "#vip_creator? returns false when the user has no payments" do
    user = users(:vip_no_payments_user)
    assert_empty user.payments
    assert_equal false, user.vip_creator?
  end

  test "#vip_creator? returns false at exactly the threshold" do
    user = users(:vip_at_threshold_user)
    assert_equal false, user.vip_creator?
  end

  test "#vip_creator? ignores non-completed payouts" do
    user = users(:vip_non_completed_user)
    assert_equal false, user.vip_creator?
  end
end
