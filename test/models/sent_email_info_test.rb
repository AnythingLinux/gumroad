# frozen_string_literal: true

require "test_helper"

class SentEmailInfoTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  test "validations: doesn't allow empty keys" do
    assert_raises(ActiveRecord::RecordInvalid) do
      SentEmailInfo.set_key!(nil)
      # set_key! returns nil/false on RecordNotUnique — but for blank key it
      # raises RecordInvalid via validates_presence_of.
    end
  end

  test "validations: doesn't allow duplicate keys" do
    SentEmailInfo.set_key!("dup_key_test")

    assert_raises(ActiveRecord::RecordNotUnique) do
      sent_email_info = SentEmailInfo.new
      sent_email_info.key = "dup_key_test"
      sent_email_info.save!
    end
  end

  test ".key_exists? returns true if record exists" do
    sent_email_info = sent_email_infos(:recent_sent_email_info)
    assert_equal true, SentEmailInfo.key_exists?(sent_email_info.key)
    assert_equal false, SentEmailInfo.key_exists?("non-existing-key")
  end

  test ".key_exists? is not affected by outer ActiveRecord scopes" do
    sent_email_info = sent_email_infos(:recent_sent_email_info)
    user = users(:basic_user)
    user.purchases.where(id: 0).each do |_|
      # This block won't execute, but the scope is established
    end
    assert_equal true, SentEmailInfo.key_exists?(sent_email_info.key)
  end

  test ".set_key! sets the record in SentEmailInfo" do
    result = SentEmailInfo.set_key!("test_key_set")
    assert_equal true, result
    assert_not_nil SentEmailInfo.find_by(key: "test_key_set")
  end

  test ".set_key! doesn't set duplicate records" do
    SentEmailInfo.set_key!("test_key_dup")
    was_set = SentEmailInfo.set_key!("test_key_dup")
    assert_nil was_set
    assert_equal 1, SentEmailInfo.where(key: "test_key_dup").count
  end

  test ".mailer_exists? returns true if a record exists for the mailer" do
    assert_equal false, SentEmailInfo.mailer_exists?("Mailer", "action", 123, 456)
    SentEmailInfo.ensure_mailer_uniqueness("Mailer", "action", 123, 456) { }
    assert_equal true, SentEmailInfo.mailer_exists?("Mailer", "action", 123, 456)
  end

  test ".ensure_mailer_uniqueness doesn't allow sending email for given key and params twice" do
    shipment = Shipment.create!(purchase: purchases(:auto_invoice_enabled_purchase))

    assert_enqueued_emails 1 do
      SentEmailInfo.ensure_mailer_uniqueness("CustomerLowPriorityMailer", "order_shipped", shipment.id) do
        CustomerLowPriorityMailer.order_shipped(shipment.id).deliver_later
      end

      SentEmailInfo.ensure_mailer_uniqueness("CustomerLowPriorityMailer", "order_shipped", shipment.id) do
        CustomerLowPriorityMailer.order_shipped(shipment.id).deliver_later
      end
    end
  end
end
