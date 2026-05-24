# frozen_string_literal: true

require "test_helper"

class PostEmailBlastTest < ActiveSupport::TestCase
  setup do
    @blast = post_email_blasts(:basic_blast)
    @post = installments(:published_post)
  end

  test ".aggregated returns aggregated rows grouped by date" do
    freeze_time do
      # Wipe the fixture row so this test controls the dataset.
      PostEmailBlast.delete_all

      PostEmailBlast.create!(post: @post, requested_at: Time.current,
                             started_at: nil, first_email_delivered_at: nil,
                             last_email_delivered_at: nil, delivery_count: 0)
      PostEmailBlast.create!(post: @post, requested_at: 1.day.ago,
                             started_at: 1.day.ago + 30.seconds,
                             first_email_delivered_at: 1.day.ago + 10.minutes,
                             last_email_delivered_at: 1.day.ago + 20.minutes,
                             delivery_count: 15)
      PostEmailBlast.create!(post: @post, requested_at: 1.day.ago,
                             started_at: 1.day.ago + 10.seconds,
                             first_email_delivered_at: 1.day.ago + 20.minutes,
                             last_email_delivered_at: 1.day.ago + 40.minutes,
                             delivery_count: 25)

      result = PostEmailBlast.aggregated.to_a
      assert_equal 2, result.size

      today_row = result.find { |r| r.date == Date.current }
      assert_equal 1, today_row.total
      assert_equal 0, today_row.total_delivery_count
      assert_nil today_row.average_start_latency

      yesterday_row = result.find { |r| r.date == 1.day.ago.to_date }
      assert_equal 2, yesterday_row.total
      assert_equal 40, yesterday_row.total_delivery_count
      assert_equal 20.0, yesterday_row.average_start_latency.to_f
      assert_equal 15.minutes.to_f, yesterday_row.average_first_email_delivery_latency.to_f
      assert_equal 30.minutes.to_f, yesterday_row.average_last_email_delivery_latency.to_f
      assert_in_delta 1.375, yesterday_row.average_deliveries_per_minute.to_f, 0.001
    end
  end

  # Latency metrics ----------------------------------------------------------

  test "#start_latency returns difference between requested_at and started_at" do
    assert_equal 5.minutes, @blast.start_latency
  end

  test "#start_latency returns nil when started_at is nil" do
    @blast.update!(started_at: nil)
    assert_nil @blast.start_latency
  end

  test "#start_latency returns nil when requested_at is nil" do
    @blast.update_columns(requested_at: nil)
    assert_nil @blast.start_latency
  end

  test "#first_email_delivery_latency returns difference between requested_at and first_email_delivered_at" do
    assert_equal 10.minutes, @blast.first_email_delivery_latency
  end

  test "#first_email_delivery_latency returns nil when first_email_delivered_at is nil" do
    @blast.update!(first_email_delivered_at: nil)
    assert_nil @blast.first_email_delivery_latency
  end

  test "#first_email_delivery_latency returns nil when requested_at is nil" do
    @blast.update_columns(requested_at: nil)
    assert_nil @blast.first_email_delivery_latency
  end

  test "#last_email_delivery_latency returns difference between requested_at and last_email_delivered_at" do
    assert_equal 20.minutes, @blast.last_email_delivery_latency
  end

  test "#last_email_delivery_latency returns nil when last_email_delivered_at is nil" do
    @blast.update!(last_email_delivered_at: nil)
    assert_nil @blast.last_email_delivery_latency
  end

  test "#last_email_delivery_latency returns nil when requested_at is nil" do
    @blast.update_columns(requested_at: nil)
    assert_nil @blast.last_email_delivery_latency
  end

  test "#deliveries_per_minute returns the deliveries per minute" do
    # 1500 deliveries in 10 minutes = 150 per minute.
    assert_equal 150.0, @blast.deliveries_per_minute
  end

  test "#deliveries_per_minute returns nil when last_email_delivered_at is nil" do
    @blast.update!(last_email_delivered_at: nil)
    assert_nil @blast.deliveries_per_minute
  end

  test "#deliveries_per_minute returns nil when first_email_delivered_at is nil" do
    @blast.update!(first_email_delivered_at: nil)
    assert_nil @blast.deliveries_per_minute
  end

  # acknowledge_email_delivery -----------------------------------------------

  test ".acknowledge_email_delivery sets first/last delivery time and increments count" do
    freeze_time do
      blast = PostEmailBlast.create!(post: @post, requested_at: Time.current,
                                     started_at: nil, first_email_delivered_at: nil,
                                     last_email_delivered_at: nil, delivery_count: 0)
      PostEmailBlast.acknowledge_email_delivery(blast.id)
      blast.reload
      assert_equal Time.current, blast.first_email_delivered_at
      assert_equal Time.current, blast.last_email_delivered_at
      assert_equal 1, blast.delivery_count
    end
  end

  test ".acknowledge_email_delivery called twice only updates last_email_delivered_at" do
    blast = PostEmailBlast.create!(post: @post, requested_at: Time.current,
                                   started_at: nil, first_email_delivered_at: nil,
                                   last_email_delivered_at: nil, delivery_count: 0)
    current_time = Time.current

    travel_to current_time do
      PostEmailBlast.acknowledge_email_delivery(blast.id)
    end

    travel_to current_time + 1.hour do
      PostEmailBlast.acknowledge_email_delivery(blast.id)
      blast.reload
      assert_equal 1.hour.ago, blast.first_email_delivered_at
      assert_equal Time.current, blast.last_email_delivered_at
      assert_equal 2, blast.delivery_count
    end
  end

  # format_datetime ----------------------------------------------------------

  test ".format_datetime returns a string without the timezone" do
    assert_equal "2001-02-03 04:05:06",
                 PostEmailBlast.format_datetime(Time.zone.local(2001, 2, 3, 4, 5, 6))
  end

  test ".format_datetime returns nil when datetime is nil" do
    assert_nil PostEmailBlast.format_datetime(nil)
  end
end
