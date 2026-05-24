require "test_helper"

class EuropeanBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    EuropeanBankAccount.new({
      user: users(:named_seller),
      account_number: "DE89370400440532013000",
      account_number_last_four: "3000",
      account_holder_full_name: "Stripe DE Account",
      account_type: "checking",
    }.merge(attrs))
  end

  def build_with_iban(iban, name: "Stripe Account")
    build(account_number: iban, account_holder_full_name: name)
  end

  test "#bank_account_type returns EU" do
    assert_equal "EU", build.bank_account_type
    assert_equal "EU", build(account_number: "FR89370400440532013000").bank_account_type
    assert_equal "EU", build(account_number: "NL89370400440532013000").bank_account_type
  end

  test "#country returns the country based on first two digits of the IBAN account number" do
    assert_equal "DE", build.country
    assert_equal "FR", build(account_number: "FR89370400440532013000").country
    assert_equal "NL", build(account_number: "NL89370400440532013000").country
  end

  test "#currency returns eur" do
    assert_equal "eur", build.currency
    assert_equal "eur", build(account_number: "FR89370400440532013000").currency
    assert_equal "eur", build(account_number: "NL89370400440532013000").currency
  end

  test "#routing_number returns nil" do
    assert_nil build.routing_number
  end

  test "#account_number_visual returns the visual account number with country code prefixed" do
    assert_equal "DE******3000", build(account_number_last_four: "3000").account_number_visual
    assert_equal "FR******3000", build(account_number: "FR89370400440532013000", account_number_last_four: "3000").account_number_visual
    assert_equal "NL******3000", build(account_number: "NL89370400440532013000", account_number_last_four: "3000").account_number_visual
  end

  test "#validate_account_number allows records that match the required account number regex" do
    Rails.env.stub(:production?, true) do
      assert build(account_number: "DE89370400440532013000").valid?
      assert build(account_number: "FR1420041010050500013M02606").valid?
      assert build(account_number: "NL91ABNA0417164300").valid?

      ba = build(account_number: "DE12345")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "893704004405320130001234567")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence

      ba = build(account_number: "NLABCDE")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
    end
  end
end
