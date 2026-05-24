require "test_helper"

class IndonesiaBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    IndonesiaBankAccount.new({
      user: users(:named_seller),
      account_number: "000123456789",
      account_number_last_four: "6789",
      bank_code: "000",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  test "#bank_account_type returns ID" do
    assert_equal "ID", build.bank_account_type
  end

  test "#country returns ID" do
    assert_equal "ID", build.country
  end

  test "#currency returns idr" do
    assert_equal "idr", build.currency
  end

  test "#routing_number returns valid for 4 characters" do
    ba = build
    assert ba.valid?, ba.errors.full_messages.to_sentence
    assert_equal "000", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******6789", build(account_number_last_four: "6789").account_number_visual
  end

  test "#validate_bank_code allows 3 to 4 alphanumeric characters only" do
    assert build(bank_code: "123").valid?
    assert build(bank_code: "1234").valid?
    assert build(bank_code: "12AB").valid?
    assert_not build(bank_code: "12").valid?
    assert_not build(bank_code: "12345").valid?
    assert_not build(bank_code: "12@#").valid?
  end
end
