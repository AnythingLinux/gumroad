# frozen_string_literal: true

require "test_helper"

class SubscriptionPlanChangeTest < ActiveSupport::TestCase
  setup do
    @membership_subscription = subscriptions(:spc_tiered_subscription)
    @nontiered_subscription = subscriptions(:spc_nontiered_subscription)
    @tier = base_variants(:spc_tier_variant)
  end

  def build_record(**attrs)
    defaults = {
      subscription: @nontiered_subscription,
      recurrence: "monthly",
      perceived_price_cents: 500,
    }
    SubscriptionPlanChange.new(**defaults.merge(attrs))
  end

  # ---- validations ----

  test "validates presence of tier for a tiered membership" do
    record = build_record(subscription: @membership_subscription, tier: nil)
    assert_not record.valid?
  end

  test "does not validate presence of tier for a non-tiered membership subscription" do
    assert_predicate build_record(tier: nil), :valid?
  end

  test "validates presence of subscription" do
    assert_not build_record(subscription: nil).valid?
  end

  test "validates presence of recurrence" do
    assert_not build_record(recurrence: nil).valid?
  end

  test "validates inclusion of recurrence in allowed recurrences" do
    BasePrice::Recurrence::ALLOWED_RECURRENCES.each do |recurrence|
      assert_predicate build_record(recurrence: recurrence), :valid?, "expected #{recurrence} to be valid"
    end
    ["biweekly", "foo"].each do |recurrence|
      assert_not build_record(recurrence: recurrence).valid?, "expected #{recurrence} to be invalid"
    end
  end

  test "validates the presence of perceived_price_cents" do
    assert_not build_record(perceived_price_cents: nil).valid?
  end

  # ---- scopes ----

  test ".applicable_for_product_price_change_as_of returns the applicable product price changes as of a given date" do
    SubscriptionPlanChange.create!(subscription: @nontiered_subscription, recurrence: "monthly", perceived_price_cents: 500, for_product_price_change: true, effective_on: 1.week.from_now)
    SubscriptionPlanChange.create!(subscription: @nontiered_subscription, recurrence: "monthly", perceived_price_cents: 500, for_product_price_change: true, effective_on: 1.day.ago, deleted_at: 12.hours.ago)
    SubscriptionPlanChange.create!(subscription: @nontiered_subscription, recurrence: "monthly", perceived_price_cents: 500, for_product_price_change: true, effective_on: 1.day.ago, applied: true)
    SubscriptionPlanChange.create!(subscription: @nontiered_subscription, recurrence: "monthly", perceived_price_cents: 500)

    applicable = SubscriptionPlanChange.create!(subscription: @nontiered_subscription, recurrence: "monthly", perceived_price_cents: 500, for_product_price_change: true, effective_on: 1.day.ago)

    assert_equal [applicable], SubscriptionPlanChange.applicable_for_product_price_change_as_of(Date.today).to_a
  end

  test ".currently_applicable returns the currently applicable plan changes" do
    SubscriptionPlanChange.create!(subscription: @nontiered_subscription, recurrence: "monthly", perceived_price_cents: 500, deleted_at: 1.week.ago)
    SubscriptionPlanChange.create!(subscription: @nontiered_subscription, recurrence: "monthly", perceived_price_cents: 500, applied: true)

    SubscriptionPlanChange.create!(subscription: @nontiered_subscription, recurrence: "monthly", perceived_price_cents: 500, for_product_price_change: true, effective_on: 1.week.from_now)
    SubscriptionPlanChange.create!(subscription: @nontiered_subscription, recurrence: "monthly", perceived_price_cents: 500, for_product_price_change: true, effective_on: 2.days.ago, notified_subscriber_at: nil)
    SubscriptionPlanChange.create!(subscription: @nontiered_subscription, recurrence: "monthly", perceived_price_cents: 500, for_product_price_change: true, effective_on: 1.day.ago, notified_subscriber_at: 1.day.ago, deleted_at: 12.hours.ago)
    SubscriptionPlanChange.create!(subscription: @nontiered_subscription, recurrence: "monthly", perceived_price_cents: 500, for_product_price_change: true, effective_on: 1.day.ago, notified_subscriber_at: 1.day.ago, applied: true)

    applicable_one = SubscriptionPlanChange.create!(subscription: @nontiered_subscription, recurrence: "monthly", perceived_price_cents: 500, for_product_price_change: true, effective_on: 1.day.ago, notified_subscriber_at: 1.day.ago)
    applicable_two = SubscriptionPlanChange.create!(subscription: @nontiered_subscription, recurrence: "monthly", perceived_price_cents: 500)

    assert_equal [applicable_one, applicable_two].sort_by(&:id),
                 SubscriptionPlanChange.currently_applicable.to_a.sort_by(&:id)
  end

  # ---- #formatted_display_price ----

  test "#formatted_display_price returns the formatted price" do
    plan_change = SubscriptionPlanChange.create!(subscription: @nontiered_subscription, recurrence: "every_two_years", perceived_price_cents: 3099)
    assert_equal "$30.99 every 2 years", plan_change.formatted_display_price

    plan_change = SubscriptionPlanChange.create!(subscription: @nontiered_subscription, recurrence: "yearly", perceived_price_cents: 1599)
    assert_equal "$15.99 a year", plan_change.formatted_display_price

    plan_change.update!(perceived_price_cents: 100, recurrence: "quarterly")
    assert_equal "$1 every 3 months", plan_change.formatted_display_price

    plan_change.update!(perceived_price_cents: 350, recurrence: "monthly")
    plan_change.subscription.link.update!(price_currency_type: "eur", price_cents: 350)
    assert_equal "€3.50 a month", plan_change.formatted_display_price
  end

  test "#formatted_display_price returns the formatted price for a subscription with a set end date" do
    @nontiered_subscription.charge_occurrence_count = 5
    @nontiered_subscription.save!(validate: false)
    plan_change = SubscriptionPlanChange.create!(subscription: @nontiered_subscription, recurrence: "monthly", perceived_price_cents: 1599)
    assert_equal "$15.99 a month x 5", plan_change.formatted_display_price
  end
end
