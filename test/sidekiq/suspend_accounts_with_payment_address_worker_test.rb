# frozen_string_literal: true

require "test_helper"

class SuspendAccountsWithPaymentAddressWorkerTest < ActiveSupport::TestCase
  test "suspends other accounts with the same payment address" do
    user = users(:basic_user)
    user_2 = users(:referrer_user)
    user.update_columns(payment_address: "sameuser@paypal.com")
    user_2.update_columns(payment_address: "sameuser@paypal.com", user_risk_state: "not_reviewed", recommendation_type: "own_products")

    SuspendAccountsWithPaymentAddressWorker.new.perform(user.id)

    user_2.reload
    assert user_2.suspended?, "expected user_2 to be suspended"
    suspended_comment = user_2.comments.where("content LIKE ?", "Suspended for fraud%").first
    assert suspended_comment, "expected a 'Suspended for fraud' comment"
    assert_includes suspended_comment.content, "sameuser@paypal.com"
    assert_includes suspended_comment.content, "payment address"
  end
end
