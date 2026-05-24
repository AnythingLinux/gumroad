require "test_helper"

class GuyanaBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    GuyanaBankAccount.new({
      user: users(:named_seller),
      account_number: "000123456789",
      account_number_last_four: "6789",
      bank_code: "AAAAGYGGXYZ",
      branch_code: "12345678",
      account_holder_full_name: "Guyana Creator",
    }.merge(attrs))
  end

  test "#bank_account_type returns GY" do
    assert_equal "GY", build.bank_account_type
  end

  test "#country returns GY" do
    assert_equal "GY", build.country
  end

  test "#currency returns gyd" do
    assert_equal "gyd", build.currency
  end

  test "#routing_number joins the bank code and branch code with a dash" do
    ba = build
    assert ba.valid?, ba.errors.full_messages.to_sentence
    assert_equal "AAAAGYGGXYZ-12345678", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******6789", build(account_number_last_four: "6789").account_number_visual
  end

  test "#validate_bank_code requires exactly 11 alphanumeric characters" do
    assert build.valid?
    assert build(bank_code: "AAAAGYGGXXX").valid?

    ["AAAAGYGG", "AAAAGYGGXX", "AAAAGYGGXXXX", "AAAAGYGG-XX"].each do |bc|
      ba = build(bank_code: bc)
      assert_not ba.valid?
      assert_equal "The bank code is invalid.", ba.errors.full_messages.to_sentence
    end
  end

  test "#validate_branch_code requires exactly 8 digits" do
    assert build(branch_code: "12345678").valid?
    assert build(branch_code: "00000000").valid?

    ["1234567", "123456789", "abcdefgh", ""].each do |bc|
      ba = build(branch_code: bc)
      assert_not ba.valid?
      assert_equal "The branch code is invalid.", ba.errors.full_messages.to_sentence
    end
  end

  test "validations skip bank_code and branch_code checks when neither has changed (legacy)" do
    ba = build
    ba.save!
    ba.update_columns(bank_number: "AAAAGYGG", branch_code: nil)
    ba.reload

    ba.account_holder_full_name = "Renamed Creator"
    assert_equal true, ba.save
  end

  test "validates branch_code when it changes on a legacy record" do
    ba = build
    ba.save!
    ba.update_columns(branch_code: nil)
    ba.reload

    ba.branch_code = "123"
    assert_not ba.valid?
    assert_equal "The branch code is invalid.", ba.errors.full_messages.to_sentence
  end

  test "validates bank_code when it changes on a legacy record" do
    ba = build
    ba.save!
    ba.update_columns(bank_number: "AAAAGYGG")
    ba.reload

    ba.bank_code = "TOOSHORT"
    assert_not ba.valid?
    assert_equal "The bank code is invalid.", ba.errors.full_messages.to_sentence
  end

  test "#validate_account_number allows records that match the required account number regex" do
    assert build.valid?
    assert build(account_number: "00012345678910111213141516171819").valid?
    assert build(account_number: "1").valid?
    assert build(account_number: "GUY12345678910111213141516171819").valid?

    ["0001234567891011121314151617181920", "GUY1234567891011121314151617181920"].each do |an|
      ba = build(account_number: an)
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
    end
  end
end
