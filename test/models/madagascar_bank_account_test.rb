require "test_helper"

class MadagascarBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    MadagascarBankAccount.new({
      user: users(:named_seller),
      account_number: "MG4800005000011234567890123",
      account_number_last_four: "0123",
      bank_code: "AAAAMGMGXXX",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  test "#bank_account_type returns Madagascar" do
    assert_equal "MG", build.bank_account_type
  end

  test "#country returns MG" do
    assert_equal "MG", build.country
  end

  test "#currency returns mga" do
    assert_equal "mga", build.currency
  end

  test "#routing_number returns valid for 11 characters" do
    ba = build
    assert ba.valid?, ba.errors.full_messages.to_sentence
    assert_equal "AAAAMGMGXXX", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******0123", build(account_number_last_four: "0123").account_number_visual
  end

  test "#validate_account_number allows records that match the required account number regex" do
    assert build.valid?
    assert build(account_number: "MG4800005000011234567890123").valid?

    ba = build(account_number: "MG12345")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

    ba = build(account_number: "DE61109010140000071219812874")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

    ba = build(account_number: "8937040044053201300000")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
  end

  test "#validate_account_number accepts an IBAN with spaces between groups" do
    assert build(account_number: "MG48 0000 5000 0112 3456 7890 123").valid?
  end

  test "#validate_account_number accepts an IBAN with dashes between groups" do
    assert build(account_number: "MG48-0000-5000-0112-3456-7890-123").valid?
  end
end
