# frozen_string_literal: true

require "test_helper"

class JapanBankAccountTest < ActiveSupport::TestCase
  def build_ba(**attrs)
    JapanBankAccount.new({
      user: users(:named_seller),
      account_number: "0001234",
      account_number_last_four: "1234",
      bank_code: "1100",
      branch_code: "000",
      account_holder_full_name: "Japanese Creator",
    }.merge(attrs))
  end

  test "#bank_account_type returns JP" do
    assert_equal "JP", build_ba.bank_account_type
  end

  test "#country returns JP" do
    assert_equal "JP", build_ba.country
  end

  test "#currency returns jpy" do
    assert_equal "jpy", build_ba.currency
  end

  test "#routing_number returns valid for 7 digits" do
    ba = build_ba
    assert ba.valid?
    assert_equal "1100000", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******8912", build_ba(account_number_last_four: "8912").account_number_visual
  end

  test "#validate_bank_code allows 4 digits only" do
    assert build_ba(bank_code: "1100", branch_code: "000").valid?
    assert_not build_ba(bank_code: "BANK", branch_code: "000").valid?
    assert_not build_ba(bank_code: "ABC", branch_code: "000").valid?
    assert_not build_ba(bank_code: "123", branch_code: "000").valid?
    assert_not build_ba(bank_code: "TESTK", branch_code: "000").valid?
    assert_not build_ba(bank_code: "12345", branch_code: "000").valid?
  end

  test "#validate_branch_code allows 3 digits only" do
    assert build_ba(bank_code: "1100", branch_code: "000").valid?
    assert_not build_ba(bank_code: "1100", branch_code: "ABC").valid?
    assert_not build_ba(bank_code: "1100", branch_code: "AB").valid?
    assert_not build_ba(bank_code: "1100", branch_code: "12").valid?
    assert_not build_ba(bank_code: "1100", branch_code: "TEST").valid?
    assert_not build_ba(bank_code: "1100", branch_code: "1234").valid?
  end

  test "#validate_account_number allows records matching required regex" do
    assert build_ba(account_number: "0001234").valid?
    assert build_ba(account_number: "1234").valid?
    assert build_ba(account_number: "12345678").valid?

    %w[ABCDEFG 123456789 123].each do |bad|
      ba = build_ba(account_number: bad)
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
    end
  end

  test "accepts Latin-only names with ASCII spaces" do
    assert build_ba(account_holder_full_name: "Japanese Creator").valid?
    assert build_ba(account_holder_full_name: "Masashi").valid?
  end

  test "accepts katakana-only names" do
    ["ヤマダタロウ", "コーヒー", "ジョージ", "ピーター・パン", "ハルナ\u3000マサシ"].each do |n|
      assert build_ba(account_holder_full_name: n).valid?, "expected valid: #{n}"
    end
  end

  test "accepts half-width katakana names" do
    ["ﾔﾏﾀﾞ\u3000ﾀﾛｳ", "ﾋﾟｰﾀｰ"].each do |n|
      assert build_ba(account_holder_full_name: n).valid?
    end
  end

  test "normalizes ASCII spaces to full-width when the rest is katakana" do
    account = build_ba(account_holder_full_name: "ハルナ マサシ")
    assert account.valid?
    assert_equal "ハルナ　マサシ", account.account_holder_full_name
  end

  test "leaves ASCII spaces alone when the name is Latin-only" do
    account = build_ba(account_holder_full_name: "Masashi Haruna")
    assert account.valid?
    assert_equal "Masashi Haruna", account.account_holder_full_name
  end

  test "rejects scripts outside the two allowed variants" do
    ["Haruna マサシ", "春奈 正志", "はるな", ""].each do |n|
      assert_not build_ba(account_holder_full_name: n).valid?, "expected invalid: #{n.inspect}"
    end
  end

  test "strips leading and trailing whitespace before validating" do
    account = build_ba(account_holder_full_name: "  Japanese Creator  ")
    assert account.valid?
    assert_equal "Japanese Creator", account.account_holder_full_name
  end

  test "does not run on soft-delete so pre-validator invalid names can be marked deleted" do
    account = build_ba
    account.save!
    account.update_columns(account_holder_full_name: "Haruna マサシ")

    account.mark_deleted!
    assert account.reload.deleted_at.present?
  end

  test "defers to presence validator for blank input instead of confusing format error" do
    account = build_ba(account_holder_full_name: "")
    assert_not account.valid?
    assert account.errors[:account_holder_full_name].present?
    assert_empty account.errors[:account_holder_full_name].grep(/katakana or Latin/)
  end
end
