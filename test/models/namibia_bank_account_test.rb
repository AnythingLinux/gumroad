require "test_helper"

class NamibiaBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    NamibiaBankAccount.new({
      user: users(:named_seller),
      account_number: "000123456789",
      account_number_last_four: "6789",
      bank_code: "AAAANANXXYZ",
      account_holder_full_name: "Namibia Creator I",
    }.merge(attrs))
  end

  test "#bank_account_type returns NA" do
    assert_equal "NA", build.bank_account_type
  end

  test "#country returns NA" do
    assert_equal "NA", build.country
  end

  test "#currency returns nad" do
    assert_equal "nad", build.currency
  end

  test "#routing_number returns valid for 8 to 11 characters" do
    assert build(bank_code: "AAAANANXXYZ").valid?
    assert build(bank_code: "AAAANANX").valid?
    assert_not build(bank_code: "AAAANANXXYZZ").valid?
    assert_not build(bank_code: "AAAANAN").valid?
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******6789", build(account_number_last_four: "6789").account_number_visual
  end

  test "#validate_account_number allows records that match the required account number regex" do
    Rails.env.stub(:production?, true) do
      assert build.valid?
      assert build(account_number: "000123456789").valid?
      assert build(account_number: "12345678").valid?
      assert build(account_number: "NAM45678").valid?
      assert build(account_number: "0001234567NAM").valid?

      ba = build(account_number: "1234567")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "12345678910111")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "0001234567NAMI")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "1234NAM")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
    end
  end
end
