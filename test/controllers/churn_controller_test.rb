# frozen_string_literal: true

require "test_helper"

class ChurnControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @seller = users(:named_seller)
    @admin = users(:admin_for_named_seller)
    @churn_data = { placeholder: "churn data" }
    @service = Object.new
    @service.define_singleton_method(:generate_data) { |*_args, **_kwargs| { placeholder: "churn data" } }
    fake = @service
    @orig_new = CreatorAnalytics::Churn.method(:new)
    CreatorAnalytics::Churn.define_singleton_method(:new) { |**_kw| fake }

    @orig_lsc = LargeSeller.method(:create_if_warranted)
    LargeSeller.define_singleton_method(:create_if_warranted) { |_user| }

    Feature.activate_user(:churn_analytics_enabled, @seller)
    sign_in @admin
    cookies.encrypted[:current_seller_id] = @seller.id
    @request.headers["X-Inertia"] = "true"
  end

  teardown do
    CreatorAnalytics::Churn.define_singleton_method(:new, @orig_new) if @orig_new
    LargeSeller.define_singleton_method(:create_if_warranted, @orig_lsc) if @orig_lsc
    Feature.deactivate_user(:churn_analytics_enabled, @seller)
    $redis.srem(RedisKey.user_ids_with_payment_requirements_key, @seller.id)
  end

  test "GET show renders churn data with supplied dates" do
    captured = nil
    @service.define_singleton_method(:generate_data) do |start_date:, end_date:|
      captured = [start_date, end_date]
      { placeholder: "churn data" }
    end
    get :show, params: { from: "2024-01-01", to: "2024-02-01" }
    assert_response :success
    page = JSON.parse(@response.body)
    assert_equal "Churn/Show", page["component"]
    assert_equal({ "placeholder" => "churn data" }, page["props"]["churn"])
    assert_equal [Date.new(2024, 1, 1), Date.new(2024, 2, 1)], captured
  end

  test "GET show passes nil dates when params are invalid" do
    captured = nil
    @service.define_singleton_method(:generate_data) do |start_date:, end_date:|
      captured = [start_date, end_date]
      { placeholder: "churn data" }
    end
    get :show, params: { from: "bad", to: "" }
    assert_response :success
    assert_equal [nil, nil], captured
  end
end
