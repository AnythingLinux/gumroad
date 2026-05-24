require "test_helper"

class HongKongBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    HongKongBankAccount.new({
      user: users(:named_seller),
      account_number: "000123456",
      branch_code: "000",
      bank_number: "110",
      account_number_last_four: "3456",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  test "#bank_account_type returns HK" do
    assert_equal "HK", build.bank_account_type
  end

  test "#country returns HK" do
    assert_equal "HK", build.country
  end

  test "#currency returns hkd" do
    assert_equal "hkd", build.currency
  end

  test "#routing_number returns valid for 6 digits with hyphen after 3" do
    ba = build
    assert ba.valid?, ba.errors.full_messages.to_sentence
    assert_equal "110-000", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******3456", build(account_number_last_four: "3456").account_number_visual
  end

  test "#validate_clearing_code allows 3 digits only" do
    assert build(clearing_code: "110").valid?
    assert build(clearing_code: "123").valid?
    assert_not build(clearing_code: "1100").valid?
    assert_not build(clearing_code: "ABC").valid?
  end

  test "#validate_branch_code allows 3 digits only" do
    assert build(branch_code: "110").valid?
    assert build(branch_code: "123").valid?
    assert_not build(branch_code: "1100").valid?
    assert_not build(branch_code: "ABC").valid?
  end

  test "#validate_account_number allows records that match the required account number regex" do
    assert build(account_number: "000123456").valid?
    assert build(account_number: "123456789").valid?
    assert build(account_number: "012345678910").valid?

    ["ABCDEFGHI", "8937040044053201300000", "CHABCDE"].each do |an|
      ba = build(account_number: an)
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
    end
  end
end
