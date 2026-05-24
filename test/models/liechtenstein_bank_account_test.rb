require "test_helper"

class LiechtensteinBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    LiechtensteinBankAccount.new({
      user: users(:named_seller),
      account_number: "LI0508800636123378777",
      account_number_last_four: "8777",
      account_holder_full_name: "Liechtenstein Creator",
    }.merge(attrs))
  end

  test "#bank_account_type returns LI" do
    assert_equal "LI", build.bank_account_type
  end

  test "#country returns LI" do
    assert_equal "LI", build.country
  end

  test "#currency returns chf" do
    assert_equal "chf", build.currency
  end

  test "#routing_number returns nil" do
    assert_nil build.routing_number
  end

  test "#account_number_visual returns the visual account number with country code prefixed" do
    assert_equal "******8777", build(account_number_last_four: "8777").account_number_visual
  end

  test "#validate_account_number allows records that match the required account number regex" do
    Rails.env.stub(:production?, true) do
      assert build.valid?
      assert build(account_number: "LI0508800636123378777").valid?

      ba = build(account_number: "LI938601111")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "LIABCDEFGHIJKLM")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "LI9386011117947123456")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "129386011117947")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
    end
  end
end
