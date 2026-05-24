require "test_helper"

class MacaoBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    MacaoBankAccount.new({
      user: users(:named_seller),
      account_number: "0000000001234567897",
      account_number_last_four: "7897",
      bank_code: "AAAAMOMXXXX",
      account_holder_full_name: "Macao Creator",
    }.merge(attrs))
  end

  test "#bank_account_type returns MO" do
    assert_equal "MO", build.bank_account_type
  end

  test "#country returns MO" do
    assert_equal "MO", build.country
  end

  test "#currency returns MOP" do
    assert_equal "mop", build.currency
  end

  test "#routing_number returns valid for 11 characters" do
    ba = build
    assert ba.valid?, ba.errors.full_messages.to_sentence
    assert_equal "AAAAMOMXXXX", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******7897", build(account_number_last_four: "7897").account_number_visual
  end

  test "#validate_account_number allows records that match the required account number regex" do
    assert build.valid?
    assert build(account_number: "0000000001234567897").valid?
    assert build(account_number: "0").valid?
    assert build(account_number: "0000123456789101").valid?

    ba = build(account_number: "00001234567891234567890")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
  end

  test "#validate_bank_code validates bank code format" do
    assert build(bank_code: "AAAAMOMXXXX").valid?
    assert build(bank_code: "BBBBMOMBXXX").valid?

    ba = build(bank_code: "INVALIDCODEE")
    assert_not ba.valid?
    assert_equal "The bank code is invalid.", ba.errors.full_messages.to_sentence
  end
end
