require "test_helper"

class ElSalvadorBankAccountTest < ActiveSupport::TestCase
  def build(**attrs)
    ElSalvadorBankAccount.new({
      user: users(:named_seller),
      account_number: "1234567890",
      account_number_last_four: "7890",
      bank_code: "AAAASVS1XXX",
      account_holder_full_name: "Salvadorian Creator",
    }.merge(attrs))
  end

  test "#bank_account_type returns SV" do
    assert_equal "SV", build.bank_account_type
  end

  test "#country returns SV" do
    assert_equal "SV", build.country
  end

  test "#currency returns usd" do
    assert_equal "usd", build.currency
  end

  test "#routing_number returns valid for 11 characters" do
    ba = build
    assert ba.valid?, ba.errors.full_messages.to_sentence
    assert_equal "AAAASVS1XXX", ba.routing_number
  end

  test "#account_number_visual returns the visual account number" do
    assert_equal "******7890", build(account_number_last_four: "7890").account_number_visual
  end

  test "#validate_bank_code allows 8 to 11 characters only" do
    assert build(bank_code: "AAAASVS1").valid?
    assert build(bank_code: "AAAASVS1XXX").valid?
    assert_not build(bank_code: "AAAASV").valid?
    assert_not build(bank_code: "AAAASVS1XXXX").valid?
  end

  test "#validate_account_number accepts plain account numbers (10-20 digits)" do
    assert build(account_number: "1234567890").valid?
    assert build(account_number: "12345678901234567890").valid?
  end

  test "#validate_account_number accepts valid SV IBAN format (28 chars)" do
    assert build(account_number: "SV44BCIE12345678901234567890").valid?
    assert build(account_number: "SV88CAGR00000000003280602160").valid?
  end

  test "#validate_account_number rejects invalid formats" do
    assert_not build(account_number: "123456789").valid?
    assert_not build(account_number: "123456789012345678901").valid?
    assert_not build(account_number: "12345ABC90").valid?
    assert_not build(account_number: "SV99BCIE12345678901234567890").valid?
  end

  test ".build_iban constructs the IBAN from a SWIFT/BIC and a plain account number" do
    assert_equal "SV88CAGR00000000003280602160", ElSalvadorBankAccount.build_iban("CAGRSVSS", "3280602160")
    assert_equal "SV44BCIE12345678901234567890", ElSalvadorBankAccount.build_iban("BCIESVS1", "12345678901234567890")
    assert_equal "SV12AAAA00000012345678901234", ElSalvadorBankAccount.build_iban("AAAASVS1XXX", "12345678901234")
  end

  test ".build_iban uppercases the bank code" do
    assert_equal "SV88CAGR00000000003280602160", ElSalvadorBankAccount.build_iban("cagrsvss", "3280602160")
  end

  test ".build_iban produces an IBAN that passes Ibandit structural validation" do
    iban = ElSalvadorBankAccount.build_iban("CAGRSVSS", "3280602160")
    assert Ibandit::IBAN.new(iban).valid?
  end

  test "#stripe_account_number constructs an IBAN when a plain account number is stored" do
    passphrase = GlobalConfig.get("STRONGBOX_GENERAL_PASSWORD")
    ba = build(account_number: "3280602160", bank_code: "CAGRSVSS", account_number_last_four: "2160")
    ba.save!
    assert_equal "SV88CAGR00000000003280602160", ba.stripe_account_number(passphrase)
  end

  test "#stripe_account_number passes through a stored IBAN unchanged" do
    passphrase = GlobalConfig.get("STRONGBOX_GENERAL_PASSWORD")
    ba = build(account_number: "SV88CAGR00000000003280602160", bank_code: "CAGRSVSS", account_number_last_four: "2160")
    ba.save!
    assert_equal "SV88CAGR00000000003280602160", ba.stripe_account_number(passphrase)
  end
end
