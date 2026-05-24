require "test_helper"

class EthiopiaBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    EthiopiaBankAccount.new({
      user: users(:named_seller),
      account_number: "0000000012345",
      account_number_last_four: "2345",
      bank_code: "AAAAETETXXX",
      account_holder_full_name: "Ethiopia Creator",
    }.merge(attrs))
  end

  test "#bank_account_type returns ET" do
    assert_equal "ET", build.bank_account_type
  end

  test "#country returns ET" do
    assert_equal "ET", build.country
  end

  test "#currency returns etb" do
    assert_equal "etb", build.currency
  end

  test "#routing_number returns valid for 11 characters" do
    ba = build
    assert ba.valid?, ba.errors.full_messages.to_sentence
    assert_equal "AAAAETETXXX", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******2345", build(account_number_last_four: "2345").account_number_visual
  end

  test "#validate_account_number allows records that match the required account number regex" do
    assert build.valid?
    assert build(account_number: "0000000012345678").valid?
    assert build(account_number: "ET00000012345678").valid?

    ba = build(account_number: "000000001234")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

    ba = build(account_number: "ET0000001234")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

    ba = build(account_number: "00000000123456789")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

    ba = build(account_number: "ET000000123456789")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
  end
end
