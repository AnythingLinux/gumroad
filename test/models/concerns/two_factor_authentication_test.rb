# frozen_string_literal: true

require "test_helper"

class TwoFactorAuthenticationTest < ActiveSupport::TestCase
  setup do
    @user = users(:named_seller)
    @user.save! if @user.external_id.blank?
    # active_model_otp generates otp_secret_key in before_create; fixtures
    # bypass callbacks, so regenerate explicitly when missing.
    if @user.otp_secret_key.blank?
      @user.otp_regenerate_secret
      @user.save!
    end
  end

  test "#otp_secret_key sets otp_secret_key for a new user" do
    assert_equal 32, @user.otp_secret_key.length
  end

  test ".find_by_encrypted_external_id finds the user" do
    assert_equal @user, User.find_by_encrypted_external_id(@user.encrypted_external_id)
  end

  test "#encrypted_external_id returns the encrypted external id" do
    assert_equal ObfuscateIds.encrypt(@user.external_id), @user.encrypted_external_id
  end

  test "#two_factor_authentication_cookie_key returns two factor authentication cookie key" do
    encrypted_id_sha = Digest::SHA256.hexdigest(@user.encrypted_external_id)[0..12]
    assert_equal "_gumroad_two_factor_#{encrypted_id_sha}", @user.two_factor_authentication_cookie_key
  end

  test "#send_authentication_token! enqueues authentication token email" do
    EmailRouterFallbackService.clear(user: @user)
    ActionMailer::Base.deliveries.clear
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    @user.send_authentication_token!
    enq = ActiveJob::Base.queue_adapter.enqueued_jobs.find { |j| j[:args].first == "TwoFactorAuthenticationMailer" }
    assert enq, "expected a TwoFactorAuthenticationMailer job to be enqueued"
    assert_equal "authentication_token", enq[:args][1]
  end

  test "#send_authentication_token! uses Resend provider when feature flag active and email recently sent" do
    EmailRouterFallbackService.clear(user: @user)
    Feature.activate(:resend_fallback_for_auth_emails)
    EmailRouterFallbackService.record_email_sent(user: @user)
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear

    @user.send_authentication_token!

    enq = ActiveJob::Base.queue_adapter.enqueued_jobs.find { |j| j[:args].first == "TwoFactorAuthenticationMailer" }
    assert enq
    # email_provider kwarg appears in the args (mailer keyword args ruby2-style hash)
    found = enq[:args].to_s.include?(MailerInfo::EMAIL_PROVIDER_RESEND)
    assert found, "expected email_provider=resend in enqueued args, got: #{enq[:args].inspect}"
  ensure
    Feature.deactivate(:resend_fallback_for_auth_emails)
  end

  test "#add_two_factor_authenticated_ip! adds the IP to redis" do
    @user.add_two_factor_authenticated_ip!("127.0.0.1")
    assert_equal "true", @user.two_factor_auth_redis_namespace.get("auth_ip_#{@user.id}_127.0.0.1")
  end

  test "#token_authenticated? returns false when token is more than 10 minutes old" do
    token = nil
    travel_to(11.minutes.ago) { token = @user.otp_code }
    assert_equal false, @user.token_authenticated?(token)
  end

  test "#token_authenticated? returns true when token is less than 10 minutes old" do
    token = nil
    travel_to(9.minutes.ago) { token = @user.otp_code }
    assert_equal true, @user.token_authenticated?(token)
  end

  test "#token_authenticated? default 000000 returns true in non-production" do
    @user.stub(:authenticate_otp, false) do
      assert_equal true, @user.token_authenticated?("000000")
    end
  end

  test "#token_authenticated? default 000000 returns false in production" do
    @user.stub(:authenticate_otp, false) do
      Rails.stub(:env, ActiveSupport::StringInquirer.new("production")) do
        assert_equal false, @user.token_authenticated?("000000")
      end
    end
  end

  test "#has_logged_in_from_ip_before? returns true when user has logged in from IP" do
    @user.add_two_factor_authenticated_ip!("127.0.0.2")
    assert_equal true, @user.has_logged_in_from_ip_before?("127.0.0.2")
  end

  test "#has_logged_in_from_ip_before? returns false when user has not logged in from IP" do
    @user.add_two_factor_authenticated_ip!("127.0.0.2")
    assert_equal false, @user.has_logged_in_from_ip_before?("127.0.0.3")
  end

  test "#totp_enabled? returns false when user has no totp credential" do
    assert_equal false, @user.totp_enabled?
  end

  test "#totp_enabled? returns false when user has an unconfirmed totp credential" do
    TotpCredential.create!(user: @user)
    assert_equal false, @user.reload.totp_enabled?
  end

  test "#totp_enabled? returns true when user has a confirmed totp credential" do
    TotpCredential.create!(user: @user, confirmed_at: Time.current)
    assert_equal true, @user.reload.totp_enabled?
  end

  test "#two_factor_auth_redis_namespace returns the redis namespace" do
    ns = @user.two_factor_auth_redis_namespace
    assert_kind_of Redis::Namespace, ns
    assert_equal :two_factor_auth_redis_namespace, ns.namespace
  end
end
