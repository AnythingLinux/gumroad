require "test_helper"

class GabonBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    GabonBankAccount.new({
      user: users(:named_seller),
      account_number: "00001234567890123456789",
      account_number_last_four: "6789",
      bank_code: "AAAAGAGAXXX",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  test "#bank_account_type returns GA" do
    assert_equal "GA", build.bank_account_type
  end

  test "#country returns GA" do
    assert_equal "GA", build.country
  end

  test "#currency returns xaf" do
    assert_equal "xaf", build.currency
  end

  test "#routing_number returns valid for 11 characters" do
    ba = build
    assert ba.valid?, ba.errors.full_messages.to_sentence
    assert_equal "AAAAGAGAXXX", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******6789", build(account_number_last_four: "6789").account_number_visual
  end

  test "#validate_bank_code allows 8 or 11 characters only" do
    assert build(bank_number: "AAAAGAGA").valid?
    assert build(bank_number: "AAAAGAGAXXX").valid?
    assert_not build(bank_number: "AAAAGAG").valid?
    assert_not build(bank_number: "AAAAGAGAXXXX").valid?
  end

  test "#validate_account_number allows records that match the required account number regex" do
    assert build.valid?
    assert build(account_number: "00012345678910111121314").valid?

    ba = build(account_number: "GA012345678910111121314")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

    ba = build(account_number: "0000123456789012345678")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

    ba = build(account_number: "000012345678901234567890")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
  end
end
