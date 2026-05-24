require "test_helper"

class LaosBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    LaosBankAccount.new({
      user: users(:named_seller),
      account_number: "000123456789",
      account_number_last_four: "6789",
      bank_code: "AAAALALAXXX",
      account_holder_full_name: "Laos Creator",
    }.merge(attrs))
  end

  test "#bank_account_type returns LA" do
    assert_equal "LA", build.bank_account_type
  end

  test "#country returns LA" do
    assert_equal "LA", build.country
  end

  test "#currency returns lak" do
    assert_equal "lak", build.currency
  end

  test "#routing_number returns valid for 11 characters" do
    ba = build
    assert ba.valid?, ba.errors.full_messages.to_sentence
    assert_equal "AAAALALAXXX", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******6789", build(account_number_last_four: "6789").account_number_visual
  end

  test "#validate_account_number allows records that match the required account number regex" do
    assert build.valid?
    assert build(account_number: "000123456789").valid?
    assert build(account_number: "0").valid?
    assert build(account_number: "000012345678910111").valid?

    ba = build(account_number: "0000123456789101111")
    assert_not ba.valid?
    assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
  end
end
