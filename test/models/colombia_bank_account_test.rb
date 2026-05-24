require "test_helper"

class ColombiaBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    ColombiaBankAccount.new({
      user: users(:named_seller),
      account_number: "000123456789",
      account_number_last_four: "6789",
      bank_code: "060",
      account_type: "savings",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  test "#bank_account_type returns CO" do
    assert_equal "CO", build.bank_account_type
  end

  test "#country returns CO" do
    assert_equal "CO", build.country
  end

  test "#currency returns cop" do
    assert_equal "cop", build.currency
  end

  test "#routing_number returns valid for 3 digits" do
    ba = build
    assert ba.valid?, ba.errors.full_messages.to_sentence
    assert_equal "060", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******6789", build(account_number_last_four: "6789").account_number_visual
  end

  test "#validate_bank_code allows 3 digits only" do
    assert build(bank_code: "060").valid?
    assert build(bank_code: "111").valid?
    assert_not build(bank_code: "ABC").valid?
    assert_not build(bank_code: "0600").valid?
    assert_not build(bank_code: "06").valid?
  end

  test "allows checking account types" do
    ba = build(account_type: ColombiaBankAccount::AccountType::CHECKING)
    assert ba.valid?
    assert_equal ColombiaBankAccount::AccountType::CHECKING, ba.account_type
  end

  test "allows savings account types" do
    ba = build(account_type: ColombiaBankAccount::AccountType::SAVINGS)
    assert ba.valid?
    assert_equal ColombiaBankAccount::AccountType::SAVINGS, ba.account_type
  end

  test "invalidates other account types" do
    ba = build(account_type: "evil_account_type")
    assert_not ba.valid?
  end

  test "translates a nil account type to the default (checking)" do
    ba = build(account_type: nil)
    assert ba.valid?
    assert_equal ColombiaBankAccount::AccountType::CHECKING, ba.account_type
  end
end
