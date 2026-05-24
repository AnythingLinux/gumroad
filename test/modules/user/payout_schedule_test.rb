# frozen_string_literal: true

require "test_helper"

class User::PayoutScheduleTest < ActiveSupport::TestCase
  fixtures :users

  # The full RSpec suite exercises #next_payout_date / #upcoming_payouts /
  # #payout_amount_for_payout_date by creating ad-hoc Balance rows at very
  # specific dates inside travel_to blocks. Static YAML fixtures can't
  # replicate that per-test distribution shape, so the instance-method
  # branches are left to be covered by Payouts service tests (already green).
  #
  # The class-level helpers (#manual_payout_end_date, #next_scheduled_payout_date,
  # #next_scheduled_payout_end_date) are pure date math and worth pinning
  # down here — they're called from the admin payouts dashboard and the
  # generate_payouts rake task.

  test ".next_scheduled_payout_date is a Friday on or after today" do
    date = User::PayoutSchedule.next_scheduled_payout_date
    assert date >= Date.today, "expected #{date} >= #{Date.today}"
    assert date.friday?, "expected #{date} (#{date.strftime('%A')}) to be a Friday"
  end

  test ".next_scheduled_payout_date marches by 7-day strides from the anchor" do
    date = User::PayoutSchedule.next_scheduled_payout_date
    anchor = User::PayoutSchedule::PAYOUT_STARTING_DATE
    assert_equal 0, (date - anchor).to_i % User::PayoutSchedule::PAYOUT_RECURRENCE_DAYS
  end

  test ".next_scheduled_payout_end_date is 7 days before the next payout" do
    assert_equal(
      User::PayoutSchedule.next_scheduled_payout_date - User::PayoutSchedule::PAYOUT_DELAY_DAYS,
      User::PayoutSchedule.next_scheduled_payout_end_date
    )
  end

  test ".manual_payout_end_date Tue–Fri returns next_scheduled_payout_end_date" do
    # Travel to noon so Date.today (system local) lands on the same wday
    # as Date.current — manual_payout_end_date branches on Date.today.wday.
    # 2024-01-09 is a Tuesday, 2024-01-12 is a Friday.
    travel_to(Time.zone.local(2024, 1, 9, 12, 0)) do
      assert_equal 2, Date.today.wday
      assert_equal User::PayoutSchedule.next_scheduled_payout_end_date,
                   User::PayoutSchedule.manual_payout_end_date
    end
    travel_to(Time.zone.local(2024, 1, 12, 12, 0)) do
      assert_equal 5, Date.today.wday
      assert_equal User::PayoutSchedule.next_scheduled_payout_end_date,
                   User::PayoutSchedule.manual_payout_end_date
    end
  end

  test ".manual_payout_end_date Sat/Sun/Mon returns one-week-earlier end date" do
    # 2024-01-13 Saturday, -14 Sunday, -15 Monday.
    [Time.zone.local(2024, 1, 13, 12, 0),
     Time.zone.local(2024, 1, 14, 12, 0),
     Time.zone.local(2024, 1, 15, 12, 0)].each do |moment|
      travel_to(moment) do
        expected = User::PayoutSchedule.next_scheduled_payout_end_date - User::PayoutSchedule::PAYOUT_DELAY_DAYS
        assert_equal expected, User::PayoutSchedule.manual_payout_end_date,
                     "on #{Date.today} (#{Date.today.strftime('%A')})"
      end
    end
  end

  test "#current_payout_processor returns PAYPAL when native payouts unsupported" do
    user = users(:basic_user)
    # basic_user has no bank account and no paypal payout email; with
    # native_payouts_supported? == false the module falls into the PAYPAL branch.
    refute user.native_payouts_supported?
    assert_equal PayoutProcessorType::PAYPAL, user.current_payout_processor
  end

  test "#next_payout_date returns nil when unpaid balance is below the minimum" do
    # basic_user has no balances at all — clearly below the minimum.
    assert_nil users(:basic_user).next_payout_date
  end

  test "#formatted_balance_for_next_payout_date returns nil when there's no upcoming date" do
    assert_nil users(:basic_user).formatted_balance_for_next_payout_date
  end

  test "constants are stable" do
    assert_equal Date.new(2012, 12, 21), User::PayoutSchedule::PAYOUT_STARTING_DATE
    assert_equal 7, User::PayoutSchedule::PAYOUT_RECURRENCE_DAYS
    assert_equal 7, User::PayoutSchedule::PAYOUT_DELAY_DAYS
    assert_equal "weekly",    User::PayoutSchedule::WEEKLY
    assert_equal "monthly",   User::PayoutSchedule::MONTHLY
    assert_equal "quarterly", User::PayoutSchedule::QUARTERLY
    assert_equal "daily",     User::PayoutSchedule::DAILY
  end
end
