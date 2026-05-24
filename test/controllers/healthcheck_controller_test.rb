# frozen_string_literal: true

require "test_helper"

class HealthcheckControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  SIDEKIQ_QUEUE_NAMES = [:critical, :default].freeze

  def stub_queue(klass, queue_name, size)
    fake = Struct.new(:size).new(size)
    siblings = (SIDEKIQ_QUEUE_NAMES - [queue_name]).map { |n| [n, Struct.new(:size).new(0)] }.to_h
    klass.stub(:new, ->(name = nil) {
      if queue_name.nil?
        fake
      elsif name == queue_name
        fake
      else
        siblings[name] || Struct.new(:size).new(0)
      end
    }) do
      yield
    end
  end

  test "GET index returns 'healthcheck' as text" do
    get :index
    assert_equal 200, response.status
    assert_equal "healthcheck", response.body
  end

  test "GET sidekiq returns ok when critical queue under limit" do
    stub_queue(Sidekiq::Queue, :critical, 11_999) do
      get :sidekiq
      assert_equal 200, response.status
      assert_equal "Sidekiq: ok", response.body
    end
  end

  test "GET sidekiq returns service_unavailable when critical queue over limit" do
    stub_queue(Sidekiq::Queue, :critical, 12_001) do
      get :sidekiq
      assert_equal 503, response.status
      assert_equal "Sidekiq: service_unavailable", response.body
    end
  end

  test "GET sidekiq returns ok when default queue under limit" do
    stub_queue(Sidekiq::Queue, :default, 299_999) do
      get :sidekiq
      assert_equal 200, response.status
      assert_equal "Sidekiq: ok", response.body
    end
  end

  test "GET sidekiq returns service_unavailable when default queue over limit" do
    stub_queue(Sidekiq::Queue, :default, 300_001) do
      get :sidekiq
      assert_equal 503, response.status
    end
  end

  test "GET sidekiq returns ok when retry set under limit" do
    stub_queue(Sidekiq::RetrySet, nil, 19_999) do
      get :sidekiq
      assert_equal 200, response.status
      assert_equal "Sidekiq: ok", response.body
    end
  end

  test "GET sidekiq returns service_unavailable when retry set over limit" do
    stub_queue(Sidekiq::RetrySet, nil, 20_001) do
      get :sidekiq
      assert_equal 503, response.status
    end
  end

  test "GET paypal_balance returns success when topup not needed" do
    $redis.set(RedisKey.paypal_topup_needed, "false")
    get :paypal_balance
    assert_equal 200, response.status
    assert_equal "PayPal balance: topup not required", response.body
  ensure
    $redis.del(RedisKey.paypal_topup_needed)
  end

  test "GET paypal_balance returns service_unavailable when key is not set" do
    $redis.del(RedisKey.paypal_topup_needed)
    get :paypal_balance
    assert_equal 503, response.status
    assert_equal "PayPal balance: topup required", response.body
  end

  test "GET paypal_balance returns service_unavailable when topup needed" do
    $redis.set(RedisKey.paypal_topup_needed, "true")
    get :paypal_balance
    assert_equal 503, response.status
  ensure
    $redis.del(RedisKey.paypal_topup_needed)
  end

  test "GET purchases returns service_unavailable when redis threshold is not set" do
    $redis.del(RedisKey.min_successful_purchases_in_last_10_minutes)
    get :purchases
    assert_equal 503, response.status
  end
end
