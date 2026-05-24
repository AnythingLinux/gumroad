require "test_helper"

class IsraelBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    IsraelBankAccount.new({
      user: users(:named_seller),
      account_number: "IL620108000000099999999",
      account_number_last_four: "9999",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  test "#bank_account_type returns IL" do
    assert_equal "IL", build.bank_account_type
  end

  test "#country returns IL" do
    assert_equal "IL", build.country
  end

  test "#currency returns ils" do
    assert_equal "ils", build.currency
  end

  test "#routing_number returns nil" do
    assert_nil build.routing_number
  end

  test "#account_number_visual returns the visual account number with country code prefixed" do
    assert_equal "IL******9999", build(account_number_last_four: "9999").account_number_visual
  end

  test "#validate_account_number allows records that match the required account number regex" do
    Rails.env.stub(:production?, true) do
      assert build.valid?
      assert build(account_number: "IL62 0108 0000 0009 9999 999").valid?

      ba = build(account_number: "IL12345")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "DE6508000000192000145399")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "8937040044053201300000")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "ILABCDE")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
    end
  end
end
