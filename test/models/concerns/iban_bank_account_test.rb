require "test_helper"

class IbanBankAccountTest < ActiveSupport::TestCase
  def build_bulgaria(**attrs)
    BulgariaBankAccount.new({
      user: users(:named_seller),
      account_number: "BG80BNBG96611020345678",
      account_number_last_four: "2874",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  def build_denmark(**attrs)
    DenmarkBankAccount.new({
      user: users(:named_seller),
      account_number: "DK5000400440116243",
      account_number_last_four: "2874",
      account_holder_full_name: "Gumbot Gumstein I",
    }.merge(attrs))
  end

  def build_san_marino(**attrs)
    SanMarinoBankAccount.new({
      user: users(:named_seller),
      account_number: "SM86U0322509800000000270100",
      account_number_last_four: "0100",
      bank_code: "AAAASMSMXXX",
      account_holder_full_name: "San Marino Creator",
    }.merge(attrs))
  end

  def build_european(**attrs)
    EuropeanBankAccount.new({
      user: users(:named_seller),
      account_number: "DE89370400440532013000",
      account_number_last_four: "3000",
      account_holder_full_name: "Stripe DE Account",
      account_type: "checking",
    }.merge(attrs))
  end

  # #stripe_external_account_country

  test "returns the IBAN's country prefix when it differs from the account country and is in SEPA" do
    assert_equal "LT", build_bulgaria(account_number: "LT121000011101001000").stripe_external_account_country
  end

  test "returns the account's home country when the IBAN matches it" do
    assert_equal "BG", build_bulgaria(account_number: "BG80BNBG96611020345678").stripe_external_account_country
  end

  test "returns the account's home country when the IBAN prefix is non-SEPA" do
    assert_equal "BG", build_bulgaria(account_number: "SA0380000000608010167519").stripe_external_account_country
  end

  test "handles non-EUR home currency accounts (Denmark with Lithuanian IBAN)" do
    assert_equal "LT", build_denmark(account_number: "LT121000011101001000").stripe_external_account_country
  end

  # #stripe_external_account_currency

  test "returns eur when the IBAN is cross-border within SEPA" do
    assert_equal "eur", build_denmark(account_number: "LT121000011101001000").stripe_external_account_currency
  end

  test "returns the account's home currency when the IBAN matches the home country" do
    assert_equal "dkk", build_denmark(account_number: "DK5000400440116243").stripe_external_account_currency
  end

  test "returns the account's home currency when the IBAN prefix is non-SEPA" do
    assert_equal "dkk", build_denmark(account_number: "SA0380000000608010167519").stripe_external_account_currency
  end

  # #stripe_external_account_routing_number

  test "returns nil when the IBAN is cross-border within SEPA, so a home-country BIC is not paired with a foreign IBAN" do
    assert_nil build_san_marino(account_number: "IT60X0542811101000000123456").stripe_external_account_routing_number
  end

  test "returns the account's routing_number when the IBAN matches the home country" do
    assert_equal "AAAASMSMXXX", build_san_marino(account_number: "SM86U0322509800000000270100").stripe_external_account_routing_number
  end

  test "returns nil for SEPA models that have no routing_number, regardless of cross-border status" do
    assert_nil build_bulgaria(account_number: "LT121000011101001000").stripe_external_account_routing_number
    assert_nil build_bulgaria(account_number: "BG80BNBG96611020345678").stripe_external_account_routing_number
  end

  # #validate_account_number

  test "accepts an IBAN whose country matches the account's home country" do
    Rails.env.stub(:production?, true) do
      assert build_bulgaria(account_number: "BG80BNBG96611020345678").valid?
    end
  end

  test "accepts a cross-border IBAN within the SEPA zone" do
    Rails.env.stub(:production?, true) do
      assert build_bulgaria(account_number: "LT121000011101001000").valid?
      assert build_denmark(account_number: "LT121000011101001000").valid?
    end
  end

  test "rejects an IBAN from a country outside the SEPA zone" do
    Rails.env.stub(:production?, true) do
      ba = build_bulgaria(account_number: "SA0380000000608010167519")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
    end
  end

  test "rejects IBANs from countries Stripe does not support (AD, VA)" do
    Rails.env.stub(:production?, true) do
      ad_account = build_bulgaria(account_number: "AD1400080001001234567890")
      assert_not ad_account.valid?
      assert_equal "The account number is invalid.", ad_account.errors.full_messages.to_sentence

      va_account = build_bulgaria(account_number: "VA59001123000012345678")
      assert_not va_account.valid?
      assert_equal "The account number is invalid.", va_account.errors.full_messages.to_sentence
    end
  end

  test "rejects an IBAN with an invalid format" do
    Rails.env.stub(:production?, true) do
      ba = build_bulgaria(account_number: "BG12345")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
    end
  end

  test "rejects a non-SEPA IBAN on EuropeanBankAccount, whose country derives from the IBAN prefix" do
    Rails.env.stub(:production?, true) do
      ba = build_european(account_number: "SA0380000000608010167519")
      assert_not ba.valid?
      assert_equal "The account number is invalid.", ba.errors.full_messages.to_sentence
    end
  end
end
