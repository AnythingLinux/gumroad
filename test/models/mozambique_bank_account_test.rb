require "test_helper"

class MozambiqueBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    MozambiqueBankAccount.new({
      user: users(:named_seller),
      account_number: "001234567890123456789",
      account_number_last_four: "6789",
      bank_code: "AAAAMZMXXXX",
      account_holder_full_name: "Mozambique Creator",
    }.merge(attrs))
  end

  test "#bank_account_type returns MZ" do
    assert_equal "MZ", build.bank_account_type
  end

  test "#country returns MZ" do
    assert_equal "MZ", build.country
  end

  test "#currency returns mzn" do
    assert_equal "mzn", build.currency
  end

  test "#routing_number returns valid for 11 characters" do
    ba = build
    assert ba.valid?, ba.errors.full_messages.to_sentence
    assert_equal "AAAAMZMXXXX", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******6789", build(account_number_last_four: "6789").account_number_visual
  end

  test "#validate_account_number allows records that match the required account number regex" do
    assert build.valid?
    assert build(account_number: "001234567890123456789").valid?
    assert_not build(account_number: "00123456789012345678").valid?
    assert_not build(account_number: "0012345678901234567890").valid?
  end
end
