require "test_helper"

class KoreaBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    KoreaBankAccount.new({
      user: users(:named_seller),
      account_number: "000123456789",
      bank_number: "SGSEKRSLXXX",
      account_number_last_four: "6789",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  test "#bank_account_type returns korea" do
    assert_equal "KR", build.bank_account_type
  end

  test "#country returns KR" do
    assert_equal "KR", build.country
  end

  test "#currency returns krw" do
    assert_equal "krw", build.currency
  end

  test "#routing_number returns valid for 11 digits" do
    ba = build
    assert ba.valid?, ba.errors.full_messages.to_sentence
    assert_equal "SGSEKRSLXXX", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******8912", build(account_number_last_four: "8912").account_number_visual
  end

  test "#validate_bank_code allows 8 to 11 characters only" do
    assert build(bank_code: "TESTKR00").valid?
    assert build(bank_code: "BANKKR001").valid?
    assert build(bank_code: "CASHKR00123").valid?

    assert_not build(bank_code: "ABCD").valid?
    assert_not build(bank_code: "1234").valid?
    assert_not build(bank_code: "TESTKR0").valid?
    assert_not build(bank_code: "TESTKR001234").valid?
  end

  test "#validate_account_number allows records that match the required account number regex" do
    assert build(account_number: "00123456789").valid?
    assert build(account_number: "0000123456789").valid?
    assert build(account_number: "000000123456789").valid?

    ba = build(account_number: "ABCDEFGHIJKL")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

    ba = build(account_number: "8937040044053201300000")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

    ba = build(account_number: "12345")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
  end
end
