require "test_helper"

class JamaicaBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    JamaicaBankAccount.new({
      user: users(:named_seller),
      bank_number: "111",
      branch_code: "00000",
      account_number: "000123456789",
      account_number_last_four: "6789",
      account_holder_full_name: "John Doe",
    }.merge(attrs))
  end

  test "#bank_account_type returns JM" do
    assert_equal "JM", build.bank_account_type
  end

  test "#country returns JM" do
    assert_equal "JM", build.country
  end

  test "#currency returns jmd" do
    assert_equal "jmd", build.currency
  end

  test "#bank_code is an alias for bank_number" do
    ba = build(bank_number: "123")
    assert_equal "123", ba.bank_code
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******6789", build(account_number_last_four: "6789").account_number_visual
  end

  test "#validate_bank_code allows 3 digits only" do
    assert build(bank_number: "123").valid?
    assert_not build(bank_number: "12").valid?
    assert_not build(bank_number: "1234").valid?
    assert_not build(bank_number: "abc").valid?
  end

  test "#validate_branch_code allows 5 digits only" do
    assert build(branch_code: "12345").valid?
    assert_not build(branch_code: "1234").valid?
    assert_not build(branch_code: "123456").valid?
    assert_not build(branch_code: "abcde").valid?
  end

  test "#validate_account_number allows 1 to 18 digits" do
    assert build(account_number: "1").valid?
    assert build(account_number: "123456789012345678").valid?
    assert_not build(account_number: "1234567890123456789").valid?
    assert_not build(account_number: "abc").valid?
  end

  test "#to_hash returns the correct hash representation" do
    ba = build(bank_number: "123", branch_code: "12345", account_number_last_four: "5678")
    hash = ba.to_hash
    assert_equal "123-12345", hash[:routing_number]
    assert_equal "******5678", hash[:account_number]
    assert_equal "JM", hash[:bank_account_type]
  end
end
