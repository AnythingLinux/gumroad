require "test_helper"

class EcuadorBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    EcuadorBankAccount.new({
      user: users(:named_seller),
      account_number: "000123456789",
      account_number_last_four: "6789",
      bank_code: "AAAAECE1XXX",
      account_holder_full_name: "Ecuadorian Creator",
    }.merge(attrs))
  end

  test "#bank_account_type returns EC" do
    assert_equal "EC", build.bank_account_type
  end

  test "#country returns EC" do
    assert_equal "EC", build.country
  end

  test "#currency returns usd" do
    assert_equal "usd", build.currency
  end

  test "#routing_number returns valid for 8 to 11 characters" do
    assert build(bank_code: "AAAAECE1").valid?
    assert build(bank_code: "AAAAECE1X").valid?
    assert build(bank_code: "AAAAECE1XX").valid?
    assert build(bank_code: "AAAAECE1XXX").valid?
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******6789", build(account_number_last_four: "6789").account_number_visual
  end

  test "#validate_account_number allows records that match the required account number regex" do
    Rails.env.stub(:production?, true) do
      assert build.valid?
      assert build(account_number: "000123456789").valid?
      assert build(account_number: "00012").valid?
      assert build(account_number: "000123456789101112").valid?

      ba = build(account_number: "EC12345")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "EC61109010140000071219812874")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "8937040044053201300")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "CRABCDE")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
    end
  end
end
