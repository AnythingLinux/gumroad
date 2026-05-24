require "test_helper"

class GhanaBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    GhanaBankAccount.new({
      user: users(:named_seller),
      account_number: "000123456789",
      account_number_last_four: "6789",
      bank_code: "022112",
      account_holder_full_name: "Ghanaian Creator",
    }.merge(attrs))
  end

  test "#bank_account_type returns GH" do
    assert_equal "GH", build.bank_account_type
  end

  test "#country returns GH" do
    assert_equal "GH", build.country
  end

  test "#currency returns ghs" do
    assert_equal "ghs", build.currency
  end

  test "#routing_number returns valid for 6 digits" do
    assert build(bank_code: "022112").valid?
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******6789", build(account_number_last_four: "6789").account_number_visual
  end

  test "#validate_account_number allows records that match the required account number regex" do
    Rails.env.stub(:production?, true) do
      assert build.valid?
      assert build(account_number: "00012345678").valid?
      assert build(account_number: "000123456789").valid?
      assert build(account_number: "00012345678912345678").valid?

      ba = build(account_number: "1234567")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "000123456789123456789")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "ABCD12345678")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
    end
  end
end
