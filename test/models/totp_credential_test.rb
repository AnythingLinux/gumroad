# frozen_string_literal: true

require "test_helper"

class TotpCredentialTest < ActiveSupport::TestCase
  setup do
    @user = users(:named_seller)
  end

  # ---- validations ----

  test "requires a user" do
    credential = TotpCredential.new
    refute_predicate credential, :valid?
    assert_predicate credential.errors[:user], :present?
  end

  test "enforces uniqueness of user_id" do
    TotpCredential.create!(user: @user)
    duplicate = TotpCredential.new(user: @user)
    refute_predicate duplicate, :valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  # ---- otp_secret ----

  test "auto-generates otp_secret on create" do
    credential = TotpCredential.create!(user: @user)
    assert_predicate credential.otp_secret, :present?
    assert_equal 32, credential.otp_secret.length
  end

  # ---- #confirmed? ----

  test "#confirmed? returns false when confirmed_at is nil" do
    credential = TotpCredential.create!(user: @user)
    refute credential.confirmed?
  end

  test "#confirmed? returns true when confirmed_at is set" do
    credential = TotpCredential.create!(user: @user, confirmed_at: Time.current)
    assert credential.confirmed?
  end

  # ---- #verify_code ----

  test "#verify_code returns true for a valid current TOTP code" do
    credential = TotpCredential.create!(user: @user, confirmed_at: Time.current)
    code = credential.otp_code
    assert credential.verify_code(code)
  end

  test "#verify_code returns false for an invalid code" do
    credential = TotpCredential.create!(user: @user, confirmed_at: Time.current)
    refute credential.verify_code("000000")
  end

  test "#verify_code accepts codes within 30-second drift" do
    credential = TotpCredential.create!(user: @user, confirmed_at: Time.current)
    code = nil
    travel_to(25.seconds.ago) { code = credential.otp_code }
    assert credential.verify_code(code)
  end

  test "#verify_code rejects codes beyond 30-second drift" do
    credential = TotpCredential.create!(user: @user, confirmed_at: Time.current)
    code = nil
    travel_to(65.seconds.ago) { code = credential.otp_code }
    refute credential.verify_code(code)
  end

  # ---- #totp_provisioning_uri ----

  test "#totp_provisioning_uri returns a valid otpauth URI" do
    credential = TotpCredential.create!(user: @user)
    uri = credential.totp_provisioning_uri
    assert uri.start_with?("otpauth://totp/")
    assert_includes uri, ERB::Util.url_encode(@user.email)
    assert_includes uri, "issuer=Gumroad"
    assert_includes uri, "secret=#{credential.otp_secret}"
  end

  # ---- #generate_recovery_codes ----

  test "#generate_recovery_codes returns 10 plaintext codes" do
    credential = TotpCredential.create!(user: @user, confirmed_at: Time.current)
    codes = credential.generate_recovery_codes
    assert_equal 10, codes.length
    codes.each do |code|
      assert_equal 8, code.length
      assert_match(/\A[A-Z0-9]+\z/, code)
    end
  end

  test "#generate_recovery_codes stores bcrypt hashes in recovery_codes" do
    credential = TotpCredential.create!(user: @user, confirmed_at: Time.current)
    credential.generate_recovery_codes
    credential.reload
    assert_kind_of Array, credential.recovery_codes
    assert_equal 10, credential.recovery_codes.length
    credential.recovery_codes.each do |h|
      assert BCrypt::Password.new(h)
    end
  end

  test "#generate_recovery_codes sets recovery_codes_generated_at" do
    credential = TotpCredential.create!(user: @user, confirmed_at: Time.current)
    freeze_time do
      credential.generate_recovery_codes
      assert_equal Time.current, credential.recovery_codes_generated_at
    end
  end

  # ---- #redeem_recovery_code ----

  test "#redeem_recovery_code returns true and removes a valid code" do
    credential = TotpCredential.create!(user: @user, confirmed_at: Time.current)
    codes = credential.generate_recovery_codes
    assert credential.redeem_recovery_code(codes.first)
    assert_equal 9, credential.reload.recovery_codes.size
  end

  test "#redeem_recovery_code is case-insensitive" do
    credential = TotpCredential.create!(user: @user, confirmed_at: Time.current)
    codes = credential.generate_recovery_codes
    assert credential.redeem_recovery_code(codes.first.downcase)
  end

  test "#redeem_recovery_code accepts codes with a dash" do
    credential = TotpCredential.create!(user: @user, confirmed_at: Time.current)
    codes = credential.generate_recovery_codes
    code = codes.second.dup
    assert credential.redeem_recovery_code(code.insert(4, "-"))
  end

  test "#redeem_recovery_code returns false for an invalid code" do
    credential = TotpCredential.create!(user: @user, confirmed_at: Time.current)
    credential.generate_recovery_codes
    refute credential.redeem_recovery_code("invalidcode")
  end

  test "#redeem_recovery_code prevents reuse of a redeemed code" do
    credential = TotpCredential.create!(user: @user, confirmed_at: Time.current)
    codes = credential.generate_recovery_codes
    credential.redeem_recovery_code(codes.first)
    refute credential.redeem_recovery_code(codes.first)
  end

  test "#redeem_recovery_code returns false when no recovery codes exist" do
    credential = TotpCredential.create!(user: @user, confirmed_at: Time.current)
    credential.update!(recovery_codes: nil)
    refute credential.redeem_recovery_code("anything")
  end
end
