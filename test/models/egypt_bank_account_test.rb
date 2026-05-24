require "test_helper"

class EgyptBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    EgyptBankAccount.new({
      user: users(:named_seller),
      account_number: "EG800002000156789012345180002",
      account_number_last_four: "1111",
      bank_code: "NBEGEGCX331",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  test "#bank_account_type returns EG" do
    assert_equal "EG", build.bank_account_type
  end

  test "#country returns EG" do
    assert_equal "EG", build.country
  end

  test "#currency returns egp" do
    assert_equal "egp", build.currency
  end

  test "#routing_number returns valid for 11 characters" do
    ba = build
    assert ba.valid?, ba.errors.full_messages.to_sentence
    assert_equal "NBEGEGCX331", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******0002", build(account_number_last_four: "0002").account_number_visual
  end

  test "#validate_bank_code allows 8 to 11 characters only" do
    assert build(bank_code: "NBEGEGCX").valid?
    assert build(bank_code: "NBEGEGCX331").valid?
    assert_not build(bank_code: "NBEGEGC").valid?
    assert_not build(bank_code: "NBEGEGCX3311").valid?
  end
end
