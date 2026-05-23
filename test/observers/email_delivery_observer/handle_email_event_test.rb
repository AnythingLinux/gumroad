# frozen_string_literal: true

require "test_helper"

class EmailDeliveryObserver::HandleEmailEventTest < ActiveSupport::TestCase
  setup do
    @user = users(:basic_user)
    @email_digest = Digest::SHA1.hexdigest(@user.email).first(12)
  end

  test ".perform logs email sent event" do
    timestamp = Time.current
    travel_to timestamp do
      message = Mail::Message.new(to: @user.email, date: timestamp)

      assert_difference -> { EmailEvent.count }, 1 do
        EmailDeliveryObserver::HandleEmailEvent.perform(message)
      end

      record = EmailEvent.find_by(email_digest: @email_digest)
      assert_equal 1, record.sent_emails_count
      assert_equal 1, record.unopened_emails_count
      assert_equal timestamp.to_i, record.last_email_sent_at.to_i
      assert_equal timestamp.to_i, record.first_unopened_email_sent_at.to_i
    end
  end
end
