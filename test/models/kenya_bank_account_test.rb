require "test_helper"

class KenyaBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    KenyaBankAccount.new({
      user: users(:named_seller),
      account_number: "000123456789",
      account_number_last_four: "6789",
      bank_code: "BARCKENXMDR",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  test "#bank_account_type returns KE" do
    assert_equal "KE", build.bank_account_type
  end

  test "#country returns KE" do
    assert_equal "KE", build.country
  end

  test "#currency returns kes" do
    assert_equal "kes", build.currency
  end

  test "#routing_number returns valid for 11 characters" do
    ba = build
    assert ba.valid?, ba.errors.full_messages.to_sentence
    assert_equal "BARCKENXMDR", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******6789", build(account_number_last_four: "6789").account_number_visual
  end

  test "#validate_bank_code allows 8 to 11 characters only" do
    assert build(bank_code: "BARCKENX").valid?
    assert build(bank_code: "BARCKENXMDR").valid?
    assert_not build(bank_code: "BARCKEN").valid?
    assert_not build(bank_code: "BARCKENXMDRX").valid?
  end
end
