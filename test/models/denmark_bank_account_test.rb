require "test_helper"

class DenmarkBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    DenmarkBankAccount.new({
      user: users(:named_seller),
      account_number: "DK5000400440116243",
      account_number_last_four: "2874",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  test "#bank_account_type returns DK" do
    assert_equal "DK", build.bank_account_type
  end

  test "#country returns DK" do
    assert_equal "DK", build.country
  end

  test "#currency returns dkk" do
    assert_equal "dkk", build.currency
  end

  test "#routing_number returns nil" do
    assert_nil build.routing_number
  end

  test "#account_number_visual returns the visual account number with country code prefixed" do
    assert_equal "DK******2874", build(account_number_last_four: "2874").account_number_visual
  end

  test "#validate_account_number allows records that match the required account number regex" do
    Rails.env.stub(:production?, true) do
      assert build.valid?
      assert build(account_number: "DK 5000 4004 4011 6243").valid?

      ba = build(account_number: "DK12345")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "DE61109010140000071219812874")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "8937040044053201300000")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "DKABCDE")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
    end
  end
end
