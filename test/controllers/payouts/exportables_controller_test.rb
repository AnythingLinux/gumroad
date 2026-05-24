# frozen_string_literal: true

require "test_helper"

class Payouts::ExportablesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @seller = users(:named_seller)
    @admin = users(:admin_for_named_seller)
    sign_in_as_seller(@admin, @seller)
  end

  teardown { restore_protect_against_forgery! }

  def completed_payment!(user:, created_at:)
    p = Payment.create!(
      user: user,
      processor: "paypal",
      processor_fee_cents: 10,
      amount_cents: 1000,
      txn_id: "txn-#{SecureRandom.hex(6)}",
      correlation_id: "cor-#{SecureRandom.hex(6)}",
      payout_period_end_date: created_at.to_date
    )
    p.update_columns(state: "completed", created_at: created_at, updated_at: created_at)
    p
  end

  test "GET index returns data with the most recent year if no year is provided" do
    p_2021_a = completed_payment!(user: @seller, created_at: Time.zone.local(2021, 1, 1))
    p_2021_b = completed_payment!(user: @seller, created_at: Time.zone.local(2021, 6, 1))
    p_2022_a = completed_payment!(user: @seller, created_at: Time.zone.local(2022, 1, 1))
    p_2022_b = completed_payment!(user: @seller, created_at: Time.zone.local(2022, 3, 1))
    p_2022_c = completed_payment!(user: @seller, created_at: Time.zone.local(2022, 6, 1))

    get :index
    body = response.parsed_body
    assert_equal [2021, 2022].sort, body["years_with_payouts"].sort
    assert_equal 2022, body["selected_year"]
    ids = body["payouts_in_selected_year"].map { |p| p["id"] }
    assert_equal [p_2022_a.external_id, p_2022_b.external_id, p_2022_c.external_id].sort, ids.sort
    _ = [p_2021_a, p_2021_b]
  end

  test "GET index falls back to most recent year if seller has no payouts in the requested year" do
    completed_payment!(user: @seller, created_at: Time.zone.local(2021, 1, 1))
    p_2022 = completed_payment!(user: @seller, created_at: Time.zone.local(2022, 1, 1))

    get :index, params: { year: 2025 }
    body = response.parsed_body
    assert_equal 2022, body["selected_year"]
    assert_equal [p_2022.external_id], body["payouts_in_selected_year"].map { |p| p["id"] }
  end

  test "GET index returns payouts for the selected year" do
    p_2021_a = completed_payment!(user: @seller, created_at: Time.zone.local(2021, 1, 1))
    p_2021_b = completed_payment!(user: @seller, created_at: Time.zone.local(2021, 6, 1))
    completed_payment!(user: @seller, created_at: Time.zone.local(2022, 1, 1))

    get :index, params: { year: 2021 }
    body = response.parsed_body
    assert_equal 2021, body["selected_year"]
    assert_equal [p_2021_a.external_id, p_2021_b.external_id].sort,
                 body["payouts_in_selected_year"].map { |p| p["id"] }.sort
  end

  test "GET index populates year-related attributes with current year when seller has no payouts" do
    get :index
    body = response.parsed_body
    assert_equal [Time.zone.now.year], body["years_with_payouts"]
    assert_equal Time.zone.now.year, body["selected_year"]
    assert_equal [], body["payouts_in_selected_year"]
  end

  test "GET index only returns completed and displayable payments" do
    p_ok_1 = completed_payment!(user: @seller, created_at: Time.zone.local(2022, 1, 1))
    p_ok_2 = completed_payment!(user: @seller, created_at: Time.zone.local(2022, 2, 1))
    Payment.create!(user: @seller, state: "processing", processor: "paypal",
                    amount_cents: 100).update_columns(created_at: Time.zone.local(2022, 2, 1), updated_at: Time.zone.local(2022, 2, 1))
    Payment.create!(user: @seller, state: "failed", processor: "paypal",
                    amount_cents: 100).update_columns(created_at: Time.zone.local(2022, 3, 1), updated_at: Time.zone.local(2022, 3, 1))
    too_old_at = PayoutsHelper::OLDEST_DISPLAYABLE_PAYOUT_PERIOD_END_DATE - 1.year
    completed_payment!(user: @seller, created_at: too_old_at)

    get :index
    body = response.parsed_body
    assert_equal [2022], body["years_with_payouts"]
    assert_equal 2022, body["selected_year"]
    assert_equal [p_ok_1.external_id, p_ok_2.external_id].sort,
                 body["payouts_in_selected_year"].map { |p| p["id"] }.sort
  end
end
