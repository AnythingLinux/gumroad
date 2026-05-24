# frozen_string_literal: false

require "test_helper"

class ForeignWebhooksControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  def stripe_signature_header(payload, secret)
    timestamp = Time.now.utc
    signature = Stripe::Webhook::Signature.compute_signature(timestamp, payload.to_json, secret)
    Stripe::Webhook::Signature.generate_header(timestamp, signature)
  end

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    [HandleStripeEventWorker, HandlePaypalEventWorker, HandleSendgridEventJob,
     LogSendgridEventWorker, HandleResendEventJob, LogResendEventJob,
     HandleSnsTranscoderEventWorker, HandleSnsMediaconvertEventWorker].each do |klass|
      klass.jobs.clear if klass.respond_to?(:jobs)
    end
  end

  # ---------- #stripe ----------
  test "stripe charge.succeeded responds successfully and enqueues HandleStripeEventWorker" do
    json = { type: "charge.succeeded", id: "evt_dafasdfadsf", pending_webhooks: "0", user_id: "1" }
    endpoint_secret = GlobalConfig.dig(:stripe, :endpoint_secret)
    @request.headers["Stripe-Signature"] = stripe_signature_header(json, endpoint_secret)
    post :stripe, params: json, as: :json
    assert_response :success
    jobs = HandleStripeEventWorker.jobs
    assert_equal 1, jobs.size
  end

  test "stripe responds with bad request for invalid stripe signature" do
    json = { type: "charge.succeeded", id: "evt_dafasdfadsf", pending_webhooks: "0", user_id: "1" }
    @request.headers["Stripe-Signature"] = "invalid"
    post :stripe, params: json
    assert_response :bad_request
    assert_equal 0, HandleStripeEventWorker.jobs.size
  end

  test "stripe responds with bad request for missing signature header" do
    json = { type: "charge.succeeded", id: "evt_dafasdfadsf", pending_webhooks: "0", user_id: "1" }
    post :stripe, params: json
    assert_response :bad_request
    assert_equal 0, HandleStripeEventWorker.jobs.size
  end

  # ---------- #stripe_connect ----------
  test "stripe_connect responds successfully and enqueues a worker" do
    json = { type: "transfer.paid", id: "evt_dafasdfadsf", pending_webhooks: "0", user_id: "acct_1234" }
    endpoint_secret = GlobalConfig.dig(:stripe_connect, :endpoint_secret)
    @request.headers["Stripe-Signature"] = stripe_signature_header(json, endpoint_secret)
    post :stripe_connect, params: json, as: :json
    assert_response :success
    assert_equal 1, HandleStripeEventWorker.jobs.size
  end

  test "stripe_connect responds with bad request for invalid stripe signature" do
    json = { type: "transfer.paid", id: "evt_dafasdfadsf", pending_webhooks: "0", user_id: "acct_1234" }
    @request.headers["Stripe-Signature"] = "invalid"
    post :stripe_connect, params: json, as: :json
    assert_response :bad_request
    assert_equal 0, HandleStripeEventWorker.jobs.size
  end

  test "stripe_connect responds with bad request for missing signature header" do
    json = { type: "transfer.paid", id: "evt_dafasdfadsf", pending_webhooks: "0", user_id: "acct_1234" }
    post :stripe_connect, params: json, as: :json
    assert_response :bad_request
    assert_equal 0, HandleStripeEventWorker.jobs.size
  end

  # ---------- #paypal ----------
  test "paypal modern webhook with valid signature enqueues HandlePaypalEventWorker" do
    payload = { event_type: "PAYMENT.CAPTURE.COMPLETED", id: "WH-123" }
    @request.headers.merge!(
      "HTTP_PAYPAL_TRANSMISSION_ID" => "abc",
      "HTTP_PAYPAL_TRANSMISSION_SIG" => "sig",
      "HTTP_PAYPAL_CERT_URL" => "https://api.paypal.com/certs/123",
      "HTTP_PAYPAL_AUTH_ALGO" => "SHA256",
      "HTTP_PAYPAL_TRANSMISSION_TIME" => Time.current.httpdate
    )
    verifier = Object.new
    verifier.define_singleton_method(:valid?) { true }
    PaypalWebhookVerifier.stub(:new, ->(**_) { verifier }) do
      with_const(:PAYPAL_WEBHOOK_ID, "TEST_WEBHOOK_ID") do
        post :paypal, params: payload, as: :json
      end
    end
    assert_response :success
    assert_equal 1, HandlePaypalEventWorker.jobs.size
  end

  test "paypal modern webhook with invalid signature returns bad_request" do
    payload = { event_type: "PAYMENT.CAPTURE.COMPLETED", id: "WH-123" }
    @request.headers.merge!(
      "HTTP_PAYPAL_TRANSMISSION_ID" => "abc",
      "HTTP_PAYPAL_TRANSMISSION_SIG" => "sig",
      "HTTP_PAYPAL_CERT_URL" => "https://api.paypal.com/certs/123",
      "HTTP_PAYPAL_AUTH_ALGO" => "SHA256",
      "HTTP_PAYPAL_TRANSMISSION_TIME" => Time.current.httpdate
    )
    verifier = Object.new
    verifier.define_singleton_method(:valid?) { false }
    PaypalWebhookVerifier.stub(:new, ->(**_) { verifier }) do
      with_const(:PAYPAL_WEBHOOK_ID, "TEST_WEBHOOK_ID") do
        post :paypal, params: payload, as: :json
      end
    end
    assert_response :bad_request
    assert_equal 0, HandlePaypalEventWorker.jobs.size
  end

  test "paypal legacy IPN payload (no event_type) skips verification and enqueues job" do
    legacy_payload = { "txn_type" => "masspay", "txn_id" => "123" }
    called = false
    PaypalWebhookVerifier.stub(:new, ->(**_) { called = true; raise "should not be called" }) do
      with_const(:PAYPAL_WEBHOOK_ID, "TEST_WEBHOOK_ID") do
        post :paypal, params: legacy_payload, as: :json
      end
    end
    refute called
    assert_response :success
    assert_equal 1, HandlePaypalEventWorker.jobs.size
  end

  # ---------- #sendgrid ----------
  test "sendgrid valid signature enqueues handlers and responds successfully" do
    ec_keys = Array.new(3) { OpenSSL::PKey::EC.generate("prime256v1") }
    public_keys = ec_keys.map { |k| Base64.strict_encode64(k.public_to_der) }
    signing_key = ec_keys.last
    timestamp = Time.current.to_i.to_s
    raw_body = [{ event: "delivered", email: "buyer@example.com", sg_message_id: "abc123" }].to_json
    digest = Digest::SHA256.digest("#{timestamp}#{raw_body}")
    signature = Base64.strict_encode64(signing_key.dsa_sign_asn1(digest))

    orig = GlobalConfig.method(:get)
    GlobalConfig.singleton_class.send(:define_method, :get) do |name, *rest|
      idx = ForeignWebhooksController::SENDGRID_WEBHOOK_PUBLIC_KEY_ENV_VARS.index(name)
      next public_keys[idx] if idx
      orig.call(name, *rest)
    end
    begin
      @request.headers["X-Twilio-Email-Event-Webhook-Signature"] = signature
      @request.headers["X-Twilio-Email-Event-Webhook-Timestamp"] = timestamp
      post :sendgrid, body: raw_body, as: :json
    ensure
      GlobalConfig.singleton_class.send(:remove_method, :get)
      GlobalConfig.define_singleton_method(:get, orig)
    end
    assert_response :success
    assert_equal 1, HandleSendgridEventJob.jobs.size
    assert_equal 1, LogSendgridEventWorker.jobs.size
  end

  test "sendgrid missing signature header returns server error and notifies" do
    raw_body = [{ event: "delivered" }].to_json
    notified = []
    orig_active = Feature.method(:active?)
    Feature.singleton_class.send(:define_method, :active?) do |flag, *rest|
      next true if flag == :verify_sendgrid_webhook_signatures
      orig_active.call(flag, *rest)
    end
    begin
      ErrorNotifier.stub(:notify, ->(msg) { notified << msg }) do
        @request.headers["X-Twilio-Email-Event-Webhook-Timestamp"] = Time.current.to_i.to_s
        post :sendgrid, body: raw_body, as: :json
      end
    ensure
      Feature.singleton_class.send(:remove_method, :active?)
      Feature.define_singleton_method(:active?, orig_active)
    end
    assert_response :internal_server_error
    assert_includes notified.first.to_s, "No public keys configured"
    assert_equal 0, HandleSendgridEventJob.jobs.size
  end

  # ---------- #resend ----------
  test "resend valid signature responds successfully and enqueues jobs" do
    timestamp = Time.current.to_i
    message_id = "msg_123"
    payload = { some: "data", and: { nested: "data" } }
    secret = "whsec_test123"
    secret_bytes = Base64.decode64(secret.split("_", 2).last)
    json = payload.to_json
    signed_payload = "#{message_id}.#{timestamp}.#{json}"
    signature = Base64.strict_encode64(OpenSSL::HMAC.digest("SHA256", secret_bytes, signed_payload))

    orig = GlobalConfig.method(:get)
    GlobalConfig.singleton_class.send(:define_method, :get) do |name, *rest|
      next secret if name == "RESEND_WEBHOOK_SECRET"
      orig.call(name, *rest)
    end
    begin
      @request.headers["svix-signature"] = "v1,#{signature}"
      @request.headers["svix-timestamp"] = timestamp.to_s
      @request.headers["svix-id"] = message_id
      post :resend, params: payload, as: :json
    ensure
      GlobalConfig.singleton_class.send(:remove_method, :get)
      GlobalConfig.define_singleton_method(:get, orig)
    end
    assert_response :success
    assert_equal 1, HandleResendEventJob.jobs.size
    assert_equal 1, LogResendEventJob.jobs.size
  end

  test "resend missing signature header returns bad_request" do
    notified = []
    ErrorNotifier.stub(:notify, ->(msg) { notified << msg }) do
      @request.headers["svix-timestamp"] = Time.current.to_i.to_s
      @request.headers["svix-id"] = "msg_123"
      post :resend, params: { foo: "bar" }, as: :json
    end
    assert_response :bad_request
    assert_includes notified.first.to_s, "Missing signature"
    assert_equal 0, HandleResendEventJob.jobs.size
  end

  # ---------- #sns ----------
  test "sns enqueues HandleSnsTranscoderEventWorker with parsed body" do
    notification = { abc: "123" }
    post :sns, body: notification.to_json, as: :json
    assert_equal 1, HandleSnsTranscoderEventWorker.jobs.size
    job = HandleSnsTranscoderEventWorker.jobs.first
    assert_equal({ "abc" => "123" }, job["args"].last)
  end

  # ---------- #mediaconvert ----------
  test "mediaconvert with valid SNS signature enqueues worker" do
    notification = { "Type" => "Notification", "Message" => { "detail" => { "jobId" => "abcd" } }.to_json }
    Aws::SNS::MessageVerifier.define_method(:authentic?) { |*_| true }
    begin
      post :mediaconvert, body: notification.to_json, as: :json
    ensure
      Aws::SNS::MessageVerifier.remove_method(:authentic?)
    end
    assert_response :success
    assert_equal 1, HandleSnsMediaconvertEventWorker.jobs.size
  end

  test "mediaconvert with invalid SNS signature renders bad_request" do
    notification = { "Type" => "Notification", "Message" => "{}" }
    Aws::SNS::MessageVerifier.define_method(:authentic?) { |*_| false }
    begin
      post :mediaconvert, body: notification.to_json, as: :json
    ensure
      Aws::SNS::MessageVerifier.remove_method(:authentic?)
    end
    assert_response :bad_request
    assert_equal 0, HandleSnsMediaconvertEventWorker.jobs.size
  end
end
