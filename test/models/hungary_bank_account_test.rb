require "test_helper"

class HungaryBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    HungaryBankAccount.new({
      user: users(:named_seller),
      account_number: "HU42117730161111101800000000",
      account_number_last_four: "2874",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  test "#bank_account_type returns HU" do
    assert_equal "HU", build.bank_account_type
  end

  test "#country returns HU" do
    assert_equal "HU", build.country
  end

  test "#currency returns huf" do
    assert_equal "huf", build.currency
  end

  test "#routing_number returns nil" do
    assert_nil build.routing_number
  end

  test "#account_number_visual returns the visual account number with country code prefixed" do
    assert_equal "HU******2874", build(account_number_last_four: "2874").account_number_visual
  end

  test "#validate_account_number allows records that match the required account number regex" do
    Rails.env.stub(:production?, true) do
      assert build.valid?
      assert build(account_number: "HU42 1177 3016 1111 1018 0000 0000").valid?

      ["HU12345", "DE61109010140000071219812874", "8937040044053201300000", "HUABCDE"].each do |an|
        ba = build(account_number: an)
        assert_not ba.valid?
        assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
      end
    end
  end
end
