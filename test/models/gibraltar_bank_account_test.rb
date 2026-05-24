require "test_helper"

class GibraltarBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    GibraltarBankAccount.new({
      user: users(:named_seller),
      account_number: "00012345",
      account_number_last_four: "2345",
      sort_code: "10-88-00",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  test "#bank_account_type returns GI" do
    assert_equal "GI", build.bank_account_type
  end

  test "#country returns GI" do
    assert_equal "GI", build.country
  end

  test "#currency returns gbp" do
    assert_equal "gbp", build.currency
  end

  test "#routing_number returns the sort code" do
    assert_equal "12-34-56", build(sort_code: "12-34-56").routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******4567", build(account_number_last_four: "4567").account_number_visual
  end

  test "#validate_sort_code allows records that match the required sort code format" do
    assert build(sort_code: "12-34-56").valid?
    assert build(sort_code: "00-00-00").valid?
    assert build(sort_code: "99-99-99").valid?
  end

  test "#validate_sort_code rejects records with invalid sort code format" do
    ["123456", "12-34-5", "AB-CD-EF", ""].each do |sc|
      ba = build(sort_code: sc)
      assert_not ba.valid?
      assert_equal "The sort code is invalid.", ba.errors.full_messages.to_sentence
    end
  end

  test "#validate_account_number allows records that match the required 8-digit account number format" do
    assert build(account_number: "01234567").valid?
    assert build(account_number: "00000000").valid?
    assert build(account_number: "99999999").valid?
  end

  test "#validate_account_number rejects records with invalid account number format" do
    ["1234567", "123456789", "ABCDEFGH", "GI75NWBK000000007099453"].each do |an|
      ba = build(account_number: an)
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
    end
  end
end
