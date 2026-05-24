# frozen_string_literal: true

require "test_helper"
require "support/controller_seller_auth_helpers"

class BraintreeControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @orig_protect = ActionController::Base.instance_method(:protect_against_forgery?)
    ActionController::Base.define_method(:protect_against_forgery?) { false }
  end

  teardown do
    ActionController::Base.define_method(:protect_against_forgery?, @orig_protect) if @orig_protect
  end

  test "#client_token returns nil clientToken when generation raises" do
    Braintree::ClientToken.stub(:generate, ->(*_a) { raise Braintree::ServerError }) do
      get :client_token
    end
    assert_equal({ clientToken: nil }.to_json, @response.body)
  end

  test "#generate_transient_customer_token returns nil when nonce or guid is missing" do
    cookies[:_gumroad_guid] = ""
    post :generate_transient_customer_token, params: { braintree_nonce: "anything" }
    assert_equal({ transient_customer_store_key: nil }.to_json, @response.body)

    cookies[:_gumroad_guid] = "we-need-a-guid"
    post :generate_transient_customer_token
    assert_equal({ transient_customer_store_key: nil }.to_json, @response.body)
  end

  test "#generate_transient_customer_token returns error on charge processor unavailable" do
    BraintreeChargeableTransientCustomer.stub(:tokenize_nonce_to_transient_customer, ->(*_a) { raise ChargeProcessorUnavailableError }) do
      cookies[:_gumroad_guid] = "we-need-a-guid"
      post :generate_transient_customer_token, params: { braintree_nonce: "anything" }
    end
    assert_equal({ error: "There is a temporary problem, please try again (your card was not charged)." }.to_json, @response.body)
  end
end
