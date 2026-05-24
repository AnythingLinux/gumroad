require "test_helper"

class GuatemalaBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    GuatemalaBankAccount.new({
      user: users(:named_seller),
      account_number: "GT20AGRO00000000001234567890",
      account_number_last_four: "7890",
      bank_code: "AAAAGTGCXYZ",
      account_holder_full_name: "Guatemala Creator",
    }.merge(attrs))
  end

  test "#bank_account_type returns GT" do
    assert_equal "GT", build.bank_account_type
  end

  test "#country returns GT" do
    assert_equal "GT", build.country
  end

  test "#currency returns gtq" do
    assert_equal "gtq", build.currency
  end

  test "#routing_number returns valid for 11 characters" do
    ba = build
    assert ba.valid?, ba.errors.full_messages.to_sentence
    assert_equal "AAAAGTGCXYZ", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******7890", build(account_number_last_four: "7890").account_number_visual
  end

  test "#validate_bank_code allows 8 to 11 characters only" do
    assert build(bank_code: "AAAAGTGCXYZ").valid?
    assert build(bank_code: "AAAAGTGC").valid?
    assert_not build(bank_code: "AAAAGTG").valid?
    assert_not build(bank_code: "AAAAGTGCXYZZ").valid?
  end
end
