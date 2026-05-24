require "test_helper"

class CzechRepublicBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    CzechRepublicBankAccount.new({
      user: users(:named_seller),
      account_number: "CZ6508000000192000145399",
      account_number_last_four: "3000",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  test "#bank_account_type returns CZ" do
    assert_equal "CZ", build.bank_account_type
  end

  test "#country returns CZ" do
    assert_equal "CZ", build.country
  end

  test "#currency returns czk" do
    assert_equal "czk", build.currency
  end

  test "#routing_number returns nil" do
    assert_nil build.routing_number
  end

  test "#account_number_visual returns the visual account number with country code prefixed" do
    assert_equal "CZ******3000", build(account_number_last_four: "3000").account_number_visual
  end

  test "#validate_account_number allows records that match the required account number regex" do
    Rails.env.stub(:production?, true) do
      assert build.valid?
      assert build(account_number: "CZ65 0800 0000 1920 0014 5399").valid?

      ba = build(account_number: "CZ12345")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "DE6508000000192000145399")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "8937040044053201300000")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "CZABCDE")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
    end
  end
end
