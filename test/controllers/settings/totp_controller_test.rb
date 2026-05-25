# frozen_string_literal: true

require "test_helper"
require "support/controller_seller_auth_helpers"

class Settings::TotpControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @user = users(:basic_user)
    sign_in_as_seller(@user)
  end

  teardown { restore_protect_against_forgery! }

  test "POST create creates totp credential and returns setup data" do
    post :create
    assert_response :success
    json = @response.parsed_body
    assert_equal true, json["success"]
    assert json["secret"].present?
    assert_match(/\Aotpauth:\/\/totp\//, json["provisioning_uri"])
    assert_includes json["provisioning_uri"], "issuer=Gumroad"
    assert_includes json["qr_svg"], "<svg"
    assert @user.reload.totp_credential.present?
    refute @user.totp_credential.confirmed?
  end

  test "POST create returns error when user already has a confirmed totp credential" do
    cred = @user.create_totp_credential!
    cred.update!(confirmed_at: Time.current)

    post :create
    assert_response :unprocessable_entity
    assert_equal false, @response.parsed_body["success"]
    assert_equal "Authenticator app is already enabled.", @response.parsed_body["error_message"]
  end

  test "POST create destroys old unconfirmed credential and creates new" do
    cred = @user.create_totp_credential!
    old_id = cred.id
    post :create
    assert_response :success
    assert_not_equal old_id, @user.reload.totp_credential.id
  end

  test "POST confirm with valid code confirms credential and returns recovery codes" do
    cred = @user.create_totp_credential!
    code = ROTP::TOTP.new(cred.otp_secret).now
    post :confirm, params: { code: }
    assert_response :success
    json = @response.parsed_body
    assert_equal true, json["success"]
    assert_kind_of Array, json["recovery_codes"]
    assert_equal 10, json["recovery_codes"].length
    json["recovery_codes"].each { |c| assert_match(/\A[A-Z0-9]{4}-[A-Z0-9]{4}\z/, c) }
    assert cred.reload.confirmed?
  end

  test "POST confirm with invalid code returns error" do
    cred = @user.create_totp_credential!
    post :confirm, params: { code: "000000" }
    assert_response :unprocessable_entity
    assert_equal "Invalid code. Please try again.", @response.parsed_body["error_message"]
    refute cred.reload.confirmed?
  end

  test "POST confirm without totp credential returns error" do
    post :confirm, params: { code: "123456" }
    assert_response :unprocessable_entity
    assert_equal "No pending TOTP setup found.", @response.parsed_body["error_message"]
  end

  test "DELETE destroy removes confirmed totp credential" do
    cred = @user.create_totp_credential!
    cred.update!(confirmed_at: Time.current)

    delete :destroy
    assert_response :success
    assert_equal true, @response.parsed_body["success"]
    assert_nil @user.reload.totp_credential
  end

  test "DELETE destroy without enabled totp returns error" do
    delete :destroy
    assert_response :unprocessable_entity
    assert_equal "Authenticator app is not enabled.", @response.parsed_body["error_message"]
  end

  test "POST regenerate_recovery_codes regenerates" do
    cred = @user.create_totp_credential!
    cred.update!(confirmed_at: Time.current)
    cred.generate_recovery_codes
    old_codes = cred.reload.recovery_codes

    post :regenerate_recovery_codes
    assert_response :success
    assert_equal 10, @response.parsed_body["recovery_codes"].length
    assert_not_equal old_codes, cred.reload.recovery_codes
  end

  test "POST regenerate_recovery_codes without enabled totp returns error" do
    post :regenerate_recovery_codes
    assert_response :unprocessable_entity
    assert_equal "Authenticator app is not enabled.", @response.parsed_body["error_message"]
  end
end
