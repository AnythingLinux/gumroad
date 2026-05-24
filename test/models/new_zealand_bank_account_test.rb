require "test_helper"

class NewZealandBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    NewZealandBankAccount.new({
      user: users(:named_seller),
      account_number: "1100000000000010",
      account_number_last_four: "0010",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  test "#bank_account_type returns new zealand" do
    assert_equal "NZ", build.bank_account_type
  end

  test "#country returns NZ" do
    assert_equal "NZ", build.country
  end

  test "#currency returns nzd" do
    assert_equal "nzd", build.currency
  end

  test "#routing_number returns nil" do
    assert_nil build.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******0010", build(account_number_last_four: "0010").account_number_visual
  end

  test "#validate_account_number allows records that match the required account number regex" do
    assert build(account_number: "1100000000000010").valid?
    assert build(account_number: "1123456789012345").valid?
    assert build(account_number: "112345678901234").valid?

    ba = build(account_number: "NZ12345")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

    ba = build(account_number: "11000000000000")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

    ba = build(account_number: "CHABCDEFGHIJKLMNZ")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
  end
end
