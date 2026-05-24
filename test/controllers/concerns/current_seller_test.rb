# frozen_string_literal: true

require "test_helper"

class CurrentSellerTest < ActionController::TestCase
  class AnonymousController < ApplicationController
    include CurrentSeller
    before_action :authenticate_user!

    def action
      head :ok
    end
  end

  tests AnonymousController

  include Devise::Test::ControllerHelpers

  setup do
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw { get "action" => "current_seller_test/anonymous#action" }
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @seller = users(:named_seller)
    @other_seller = users(:another_seller)
    @orig_protect = ActionController::Base.instance_method(:protect_against_forgery?)
    ActionController::Base.define_method(:protect_against_forgery?) { false }
  end

  teardown do
    ActionController::Base.define_method(:protect_against_forgery?, @orig_protect) if @orig_protect
  end

  test "with seller signed in and correct cookie keeps cookie and assigns current_seller" do
    sign_in @seller
    @request.cookie_jar.encrypted[:current_seller_id] = @seller.id
    get :action
    assert_equal @seller, @controller.current_seller
    assert_equal @seller.id, cookies.encrypted[:current_seller_id]
  end

  test "with seller signed in and deleted other-seller cookie deletes cookie and assigns own seller" do
    sign_in @seller
    @other_seller.update!(deleted_at: Time.current)
    @request.cookie_jar.encrypted[:current_seller_id] = @other_seller.id
    get :action
    assert_equal @seller, @controller.current_seller
    assert_nil cookies.encrypted[:current_seller_id]
  end

  test "with seller signed in and invalid cookie value deletes cookie and assigns own seller" do
    sign_in @seller
    @request.cookie_jar.encrypted[:current_seller_id] = "foo"
    get :action
    assert_equal @seller, @controller.current_seller
    assert_nil cookies.encrypted[:current_seller_id]
  end

  test "with seller signed in and cookie pointing at a non-member seller deletes cookie" do
    sign_in @seller
    @request.cookie_jar.encrypted[:current_seller_id] = @other_seller.id
    get :action
    assert_equal @seller, @controller.current_seller
    assert_nil cookies.encrypted[:current_seller_id]
  end

  test "with seller signed in and no cookie assigns seller as current_seller" do
    sign_in @seller
    get :action
    assert_equal @seller, @controller.current_seller
    assert_nil cookies.encrypted[:current_seller_id]
  end
end
