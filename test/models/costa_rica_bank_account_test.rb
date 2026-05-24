require "test_helper"

class CostaRicaBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    CostaRicaBankAccount.new({
      user: users(:named_seller),
      account_number: "CR04010212367856709123",
      account_number_last_four: "9123",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  test "#bank_account_type returns CR" do
    assert_equal "CR", build.bank_account_type
  end

  test "#country returns CR" do
    assert_equal "CR", build.country
  end

  test "#currency returns crc" do
    assert_equal "crc", build.currency
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "CR******9123", build(account_number_last_four: "9123").account_number_visual
  end

  test "#validate_account_number allows records that match the required account number regex" do
    Rails.env.stub(:production?, true) do
      assert build.valid?
      assert build(account_number: "CR 0401 0212 3678 5670 9123").valid?

      ba = build(account_number: "CR12345")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "DE61109010140000071219812874")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "8937040044053201300000")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "CRABCDE")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
    end
  end
end
