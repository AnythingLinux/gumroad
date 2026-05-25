# frozen_string_literal: true

require "test_helper"

class TwoFactorAuthenticationValidatorTest < ActionController::TestCase
  class AnonymousController < ApplicationController
    before_action :authenticate_user!
    include TwoFactorAuthenticationValidator

    def action
      head :ok
    end
  end

  tests AnonymousController

  include Devise::Test::ControllerHelpers

  setup do
    WebMock.stub_request(:get, %r{api\.pwnedpasswords\.com/range/.*}).to_return(status: 200, body: "")
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw { get "action" => "two_factor_authentication_validator_test/anonymous#action" }
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = users(:two_factor_user)
    sign_in @user
    @orig_protect = ActionController::Base.instance_method(:protect_against_forgery?)
    ActionController::Base.define_method(:protect_against_forgery?) { false }
  end

  teardown do
    ActionController::Base.define_method(:protect_against_forgery?, @orig_protect) if @orig_protect
  end

  test "#skip_two_factor_authentication? returns true when 2FA disabled" do
    @user.update_columns(flags: (@user.flags || 0) & ~(1 << 8))
    @user.reload
    refute @user.two_factor_authentication_enabled?
    get :action
    assert_equal true, @controller.skip_two_factor_authentication?(@user)
  end

  test "#skip_two_factor_authentication? returns true when verified IP is recorded" do
    get :action
    @user.add_two_factor_authenticated_ip!("0.0.0.0")
    assert_equal true, @controller.skip_two_factor_authentication?(@user)
  end

  test "#set_two_factor_auth_cookie sets the encrypted cookie" do
    travel_to(Time.current) do
      get :action
      @controller.set_two_factor_auth_cookie(@user)
      expires_at = 2.months.from_now.to_i
      cookie_value = "#{@user.id},#{expires_at}"
      assert_equal cookie_value, @controller.send(:cookies).encrypted[@user.two_factor_authentication_cookie_key]
    end
  end

  test "#valid_two_factor_cookie_present? returns false when cookie missing" do
    get :action
    refute @controller.send(:valid_two_factor_cookie_present?, @user)
  end

  test "#prepare_for_two_factor_authentication sets user_id in session" do
    get :action
    @controller.prepare_for_two_factor_authentication(@user)
    assert_equal @user.id, session[:verify_two_factor_auth_for]
  end

  test "#two_factor_auth_method= updates the auth method in session" do
    get :action
    @controller.prepare_for_two_factor_authentication(@user)
    @controller.two_factor_auth_method = "recovery"
    assert_equal "recovery", @controller.two_factor_auth_method
  end

  test "#user_for_two_factor_authentication returns the user from session" do
    get :action
    @controller.prepare_for_two_factor_authentication(@user)
    assert_equal @user, @controller.user_for_two_factor_authentication
  end

  test "#reset_two_factor_auth_login_session removes session keys" do
    get :action
    @controller.prepare_for_two_factor_authentication(@user)
    @controller.reset_two_factor_auth_login_session
    assert_nil session[:verify_two_factor_auth_for]
    assert_nil session[:two_factor_auth_method]
  end
end
