# frozen_string_literal: true

require "test_helper"

class User::AsyncDeviseNotificationTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  fixtures :users

  setup do
    @user = users(:basic_user)
  end

  [
    ["send_confirmation_instructions", "confirmation_instructions"],
    ["send_reset_password_instructions", "reset_password_instructions"],
  ].each do |devise_email_method, devise_email_name|
    test "#{devise_email_method} queues the #{devise_email_name} email in the background" do
      assert_enqueued_with(job: ActionMailer::MailDeliveryJob, queue: "critical") do
        @user.public_send(devise_email_method)
      end
      enqueued = ActiveJob::Base.queue_adapter.enqueued_jobs.last
      assert_equal "UserSignupMailer", enqueued[:args][0]
      assert_equal devise_email_name, enqueued[:args][1]
    end

    test "#{devise_email_method} actually invokes UserSignupMailer.#{devise_email_name} when the job runs" do
      # Stub out the mailer entry-point to avoid Premailer reaching for built
      # vite assets (deliver_now otherwise needs /vite-test/entrypoints/email.scss).
      # ActionMailer methods are routed via method_missing, so capture via the
      # generic .method_missing override instead of alias_method.
      called = []
      fake_mail = Object.new
      fake_mail.define_singleton_method(:deliver_now) { :delivered }
      fake_mail.define_singleton_method(:deliver_later) { |*_| :enqueued }
      sig_class = UserSignupMailer.singleton_class
      target = devise_email_name.to_sym
      sig_class.send(:define_method, target) do |*args, **opts|
        called << [args, opts]
        fake_mail
      end
      begin
        perform_enqueued_jobs do
          @user.public_send(devise_email_method)
        end
      ensure
        sig_class.send(:remove_method, target) if sig_class.method_defined?(target) || sig_class.private_method_defined?(target)
      end
      assert_equal 1, called.length, "expected UserSignupMailer.#{devise_email_name} to be invoked exactly once"
    end
  end
end
