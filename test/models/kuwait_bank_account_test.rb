require "test_helper"

class KuwaitBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    KuwaitBankAccount.new({
      user: users(:named_seller),
      bank_code: "AAAAKWKWXYZ",
      account_number: "KW81CBKU0000000000001234560101",
      account_number_last_four: "0101",
      account_holder_full_name: "Kuwaiti Creator",
    }.merge(attrs))
  end

  test "#bank_account_type returns KW" do
    assert_equal "KW", build.bank_account_type
  end

  test "#country returns KW" do
    assert_equal "KW", build.country
  end

  test "#currency returns kwd" do
    assert_equal "kwd", build.currency
  end

  test "#routing_number returns valid for 10 characters" do
    ba = build
    assert ba.valid?, ba.errors.full_messages.to_sentence
    assert_equal "AAAAKWKWXYZ", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******0101", build(account_number_last_four: "0101").account_number_visual
  end

  test "#validate_bank_code allows only 8 to 11 characters" do
    assert build(bank_code: "AAAAKWKWXYZ").valid?
    assert build(bank_code: "AAA0000X").valid?
    assert_not build(bank_code: "AAAA0000XXXX").valid?
    assert_not build(bank_code: "AAAA000").valid?
  end

  test "#validate_account_number allows only 30 characters in the correct format" do
    assert build(account_number: "KW81CBKU0000000000001234560101").valid?
    assert_not build(account_number: "KW81CBKU00000000000012345601012").valid?
    assert_not build(account_number: "KW81CBKU000000000000123456").valid?
    assert_not build(account_number: "KW81CBKU0000000000001234560101234").valid?
  end
end
