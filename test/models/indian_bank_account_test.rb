require "test_helper"

class IndianBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    IndianBankAccount.new({
      user: users(:named_seller),
      account_number: "000123456789",
      account_number_last_four: "6789",
      ifsc: "HDFC0004051",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  test "#bank_account_type returns IN" do
    assert_equal "IN", build.bank_account_type
  end

  test "#country returns IN" do
    assert_equal "IN", build.country
  end

  test "#currency returns inr" do
    assert_equal "inr", build.currency
  end

  test "#routing_number returns valid for 11 characters" do
    ba = build
    assert ba.valid?, ba.errors.full_messages.to_sentence
    assert_equal "HDFC0004051", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******6789", build(account_number_last_four: "6789").account_number_visual
  end

  test "#validate_ifsc allows 11 characters only" do
    assert build(ifsc: "HDFC0004051").valid?
    assert build(ifsc: "ICIC0123456").valid?
    assert_not build(ifsc: "HDFC00040511").valid?
    assert_not build(ifsc: "HDFC000405").valid?
  end
end
