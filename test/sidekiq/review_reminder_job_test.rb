# frozen_string_literal: true

require "test_helper"

class ReviewReminderJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  setup do
    @purchase = purchases(:email_sync_purchase_a)
  end

  test "enqueues purchase_review_reminder mailer when eligible" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      ReviewReminderJob.new.perform(@purchase.id)
    end
  end

  test "does not enqueue when purchase has a review" do
    ProductReview.create!(purchase_id: @purchase.id, link_id: @purchase.link_id, rating: 5, message: "Great")
    assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      ReviewReminderJob.new.perform(@purchase.id)
    end
  end

  test "does not enqueue when purchase was refunded" do
    @purchase.update!(stripe_refunded: true)
    assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      ReviewReminderJob.new.perform(@purchase.id)
    end
  end

  test "does not enqueue when purchase was chargebacked" do
    @purchase.update!(chargeback_date: Time.current)
    assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      ReviewReminderJob.new.perform(@purchase.id)
    end
  end

  test "enqueues when chargeback was reversed" do
    @purchase.update!(chargeback_date: Time.current, chargeback_reversed: true)
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      ReviewReminderJob.new.perform(@purchase.id)
    end
  end

  test "does not enqueue when purchaser opted out of review reminders" do
    @purchase.purchaser.update!(opted_out_of_review_reminders: true)
    assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      ReviewReminderJob.new.perform(@purchase.id)
    end
  end
end
