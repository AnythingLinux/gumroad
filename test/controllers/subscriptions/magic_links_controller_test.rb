# frozen_string_literal: true

require "test_helper"

class Subscriptions::MagicLinksControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    boot_controller_test!
    @subscription = subscriptions(:magic_link_subscription)
    @purchase = purchases(:magic_link_membership_purchase)
    @subscriber = @subscription.user
  end

  teardown { restore_protect_against_forgery! }

  test "GET new renders the magic link page with correct component and props" do
    get :new, params: { subscription_id: @subscription.external_id }
    assert_response :success
    json = response.parsed_body
    expected_props = Subscriptions::MagicLinkPresenter.new(subscription: @subscription).magic_link_props
    if json.is_a?(Hash) && json["component"]
      assert_equal "Subscriptions/MagicLinks/New", json["component"]
      props = json["props"].deep_symbolize_keys
      expected_props.each { |k, v| assert_equal v, props[k] }
      assert_nil props[:email_sent]
    end
  end

  test "GET new passes email_sent prop to the page when present" do
    get :new, params: { subscription_id: @subscription.external_id, email_sent: "user" }
    assert_response :success
    json = response.parsed_body
    if json.is_a?(Hash) && json["props"]
      assert_equal "user", json["props"].deep_symbolize_keys[:email_sent]
    end
  end

  test "GET new returns 404 when subscription does not exist" do
    assert_raises(ActionController::RoutingError) do
      get :new, params: { subscription_id: "non_existent_id" }
    end
  end

  test "POST create returns 404 when subscription does not exist" do
    assert_raises(ActionController::RoutingError) do
      post :create, params: { subscription_id: "non_existent_id", email_source: "user" }
    end
  end

  test "POST create sets up the token in the subscription" do
    assert_nil @subscription.token
    post :create, params: { subscription_id: @subscription.external_id, email_source: "user" }
    assert_not_nil @subscription.reload.token
  end

  test "POST create sets the token to expire in 24 hours" do
    assert_nil @subscription.token_expires_at
    post :create, params: { subscription_id: @subscription.external_id, email_source: "user" }
    assert_in_delta 24.hours.from_now.to_i, @subscription.reload.token_expires_at.to_i, 5
  end

  test "POST create sends the magic link email and redirects with flash" do
    sent = []
    fake_mail = Object.new
    fake_mail.define_singleton_method(:deliver_later) { |*_a, **_k| nil }
    original = CustomerMailer.method(:subscription_magic_link)
    CustomerMailer.define_singleton_method(:subscription_magic_link) do |*args|
      sent << args
      fake_mail
    end
    begin
      post :create, params: { subscription_id: @subscription.external_id, email_source: "user" }
    ensure
      CustomerMailer.define_singleton_method(:subscription_magic_link, original)
    end
    assert_equal 1, sent.length
    assert_equal @subscription.id, sent.first.first
    assert_redirected_to new_subscription_magic_link_path(@subscription.external_id, email_sent: "user")
    assert_includes flash[:notice].to_s, "Magic link sent"
  end

  test "POST create with email_source=user emails the subscribing user's email" do
    @purchase.update_columns(email: "purchase@email.com")
    @subscriber.update_columns(email: "subscriber@email.com")

    sent = []
    fake_mail = Object.new
    fake_mail.define_singleton_method(:deliver_later) { |*_a, **_k| nil }
    original = CustomerMailer.method(:subscription_magic_link)
    CustomerMailer.define_singleton_method(:subscription_magic_link) do |*args|
      sent << args
      fake_mail
    end
    begin
      post :create, params: { subscription_id: @subscription.external_id, email_source: "user" }
    ensure
      CustomerMailer.define_singleton_method(:subscription_magic_link, original)
    end
    assert_equal "subscriber@email.com", sent.first.last
    assert_redirected_to new_subscription_magic_link_path(@subscription.external_id, email_sent: "user")
  end

  test "POST create with email_source=purchase emails the original purchase email" do
    @purchase.update_columns(email: "purchase@email.com")

    sent = []
    fake_mail = Object.new
    fake_mail.define_singleton_method(:deliver_later) { |*_a, **_k| nil }
    original = CustomerMailer.method(:subscription_magic_link)
    CustomerMailer.define_singleton_method(:subscription_magic_link) do |*args|
      sent << args
      fake_mail
    end
    begin
      post :create, params: { subscription_id: @subscription.external_id, email_source: "purchase" }
    ensure
      CustomerMailer.define_singleton_method(:subscription_magic_link, original)
    end
    assert_equal "purchase@email.com", sent.first.last
    assert_redirected_to new_subscription_magic_link_path(@subscription.external_id, email_sent: "purchase")
  end

  test "POST create with invalid email_source raises 404" do
    assert_raises(ActionController::RoutingError) do
      post :create, params: { subscription_id: @subscription.external_id, email_source: "invalid_source" }
    end
  end
end
