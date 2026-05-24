# frozen_string_literal: true

require "test_helper"

class User::PurchasesTest < ActiveSupport::TestCase
  setup do
    @user = users(:transfer_source_user)
    @new_user = users(:transfer_target_user)
  end

  test "#transfer_purchases! transfers purchases to the new user" do
    purchases = [purchases(:transfer_purchase_0), purchases(:transfer_purchase_1), purchases(:transfer_purchase_2)]

    @user.transfer_purchases!(new_email: @new_user.email)

    purchases.each do |purchase|
      purchase.reload
      assert_equal @new_user.email, purchase.email
      assert_equal @new_user, purchase.purchaser
    end
  end

  test "#transfer_purchases! raises ActiveRecord::RecordNotFound if the new user does not exist" do
    assert_raises(ActiveRecord::RecordNotFound) do
      @user.transfer_purchases!(new_email: "nonexistent-#{SecureRandom.hex(4)}@example.com")
    end
  end
end
