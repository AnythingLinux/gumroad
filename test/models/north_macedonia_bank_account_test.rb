require "test_helper"

class NorthMacedoniaBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    NorthMacedoniaBankAccount.new({
      user: users(:named_seller),
      account_number: "MK49250120000058907",
      account_number_last_four: "8907",
      account_holder_full_name: "Gumbot Gumstein I",
      bank_code: "AAAAMK2XXXX",
    }.merge(attrs))
  end

  test "#bank_account_type returns Macedonia" do
    assert_equal "MK", build.bank_account_type
  end

  test "#country returns MK" do
    assert_equal "MK", build.country
  end

  test "#currency returns mkd" do
    assert_equal "mkd", build.currency
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "MK******2345", build(account_number_last_four: "2345").account_number_visual
  end

  test "#validate_bank_code allows records that match the required bank code format" do
    assert build(bank_code: "AAAAMK2XXXX").valid?
    assert build(bank_code: "AAAAMK2X").valid?

    ba = build(bank_code: "AAAAMK2XXXXX")
    assert_not ba.valid?
    assert_includes ba.errors[:base], "The bank code is invalid."

    ba = build(bank_code: "AAAA2MK")
    assert_not ba.valid?
    assert_includes ba.errors[:base], "The bank code is invalid."
  end

  test "#validate_account_number allows records that match the required account number regex" do
    Rails.env.stub(:production?, true) do
      assert build.valid?
      assert build(account_number: "MK07250120000058984").valid?
      assert build(account_number: "ABC7250120000058984").valid?
      assert build(account_number: "0007250120000058984").valid?
      assert build(account_number: "ABCDEFGHIJKLMNOPQRS").valid?

      ba = build(account_number: "MK0725012000005898")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "MK072501200000589845")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "00072501200000589845")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "ABCDEFGHIJKLMNOPQR")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
    end
  end

  test "#routing_number returns the bank code" do
    ba = build(bank_code: "AAAAMK2XXXX")
    assert_equal "AAAAMK2XXXX", ba.routing_number
  end

  test "#to_hash returns hash with bank account details" do
    ba = build(bank_code: "AAAAMK2XXXX", account_number_last_four: "8907")

    assert_equal({
      routing_number: "AAAAMK2XXXX",
      account_number: "MK******8907",
      bank_account_type: "MK"
    }, ba.to_hash)
  end
end
