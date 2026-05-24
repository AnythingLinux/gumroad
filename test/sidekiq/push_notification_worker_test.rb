# frozen_string_literal: true

require "test_helper"

class PushNotificationWorkerTest < ActiveSupport::TestCase
  setup do
    @user = users(:named_seller)
    @user.devices.destroy_all
    @device_a = @user.devices.create!(token: "ios-token-a", device_type: "ios", app_type: Device::APP_TYPES[:creator])
    @device_b = @user.devices.create!(token: "android-token-b", device_type: "android", app_type: Device::APP_TYPES[:creator])
    @device_c = @user.devices.create!(token: "ios-token-c", device_type: "ios", app_type: Device::APP_TYPES[:creator])

    @ios_news = []
    @android_news = []
    @processes = []

    PushNotificationService::Ios.define_singleton_method(:new) do |**kwargs|
      svc = Object.new
      kwargs_dup = kwargs.dup
      svc.define_singleton_method(:kwargs) { kwargs_dup }
      svc.define_singleton_method(:process) { PushNotificationWorkerTest.processes_log << [:ios, kwargs_dup] }
      PushNotificationWorkerTest.ios_news_log << kwargs_dup
      svc
    end
    PushNotificationService::Android.define_singleton_method(:new) do |**kwargs|
      svc = Object.new
      kwargs_dup = kwargs.dup
      svc.define_singleton_method(:process) { PushNotificationWorkerTest.processes_log << [:android, kwargs_dup] }
      PushNotificationWorkerTest.android_news_log << kwargs_dup
      svc
    end
    self.class.class_variable_set(:@@ios_log, @ios_news)
    self.class.class_variable_set(:@@android_log, @android_news)
    self.class.class_variable_set(:@@process_log, @processes)
  end

  def self.ios_news_log; class_variable_get(:@@ios_log); end
  def self.android_news_log; class_variable_get(:@@android_log); end
  def self.processes_log; class_variable_get(:@@process_log); end

  teardown do
    [PushNotificationService::Ios, PushNotificationService::Android].each do |klass|
      klass.singleton_class.send(:remove_method, :new) if klass.singleton_class.method_defined?(:new)
    end
  end

  test "sends notification to each of the user's devices for the given app_type" do
    PushNotificationWorker.new.perform(@user.id, Device::APP_TYPES[:creator], "Title", "Body", {}, Device::NOTIFICATION_SOUNDS[:sale])

    assert_equal 2, @ios_news.size
    assert_equal 1, @android_news.size
    assert_equal 3, @processes.size
    tokens = @ios_news.map { |kw| kw[:device_token] } + @android_news.map { |kw| kw[:device_token] }
    assert_equal ["ios-token-a", "ios-token-c", "android-token-b"].sort, tokens.sort
    @ios_news.each do |kw|
      assert_equal "Title", kw[:title]
      assert_equal "Body", kw[:body]
      assert_equal Device::APP_TYPES[:creator], kw[:app_type]
      assert_equal Device::NOTIFICATION_SOUNDS[:sale], kw[:sound]
    end
  end

  test "only sends to devices matching the requested app_type" do
    @user.devices.create!(token: "ios-token-d", device_type: "ios", app_type: Device::APP_TYPES[:consumer])

    PushNotificationWorker.new.perform(@user.id, Device::APP_TYPES[:consumer], "Title", "Body", {})

    tokens = @ios_news.map { |kw| kw[:device_token] }
    assert_equal ["ios-token-d"], tokens
    assert_empty @android_news
  end
end
