# frozen_string_literal: true

require "test_helper"

class Payouts::ExportsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @seller = users(:named_seller)
    @admin = users(:admin_for_named_seller)
    sign_in_as_seller(@admin, @seller)
    ExportPayoutData.jobs.clear
  end

  teardown { restore_protect_against_forgery! }

  def completed_payment!(user:, created_at: Time.current)
    p = Payment.create!(
      user: user, processor: "paypal", processor_fee_cents: 10,
      amount_cents: 1000, txn_id: "txn-#{SecureRandom.hex(6)}",
      correlation_id: "cor-#{SecureRandom.hex(6)}", payout_period_end_date: created_at.to_date
    )
    p.update_columns(state: "completed", created_at: created_at, updated_at: created_at)
    p
  end

  test "POST create returns unprocessable_entity when no parameters are provided" do
    post :create, format: :json
    assert_response :unprocessable_entity
    assert_equal "Invalid payouts", response.parsed_body["error"]
  end

  test "POST create returns unprocessable_entity for invalid parameters" do
    post :create, params: { payment_ids: ["invalid_id"] }, format: :json
    assert_response :unprocessable_entity
    assert_equal "Invalid payouts", response.parsed_body["error"]

    post :create, params: { payment_ids: [] }, format: :json
    assert_response :unprocessable_entity
    assert_equal "Invalid payouts", response.parsed_body["error"]

    post :create, params: { payment_ids: "invalid_id" }, format: :json
    assert_response :unprocessable_entity
    assert_equal "Invalid payouts", response.parsed_body["error"]
  end

  test "POST create queues an export job when valid parameters are provided" do
    p1 = completed_payment!(user: @seller)
    p2 = completed_payment!(user: @seller)

    assert_difference -> { ExportPayoutData.jobs.size }, 1 do
      post :create, params: { payout_ids: [p1.external_id, p2.external_id] }, format: :json
    end
    assert_response :ok

    job = ExportPayoutData.jobs.last
    assert_equal [p1.id, p2.id].sort, job["args"][0].sort
    assert_equal @admin.id, job["args"][1]
  end

  test "POST create returns unprocessable_entity when a payout for a different seller is given" do
    other_seller = users(:basic_user)
    other_payout = completed_payment!(user: other_seller)

    assert_no_difference -> { ExportPayoutData.jobs.size } do
      post :create, params: { payout_ids: [other_payout.external_id] }, format: :json
    end
    assert_response :unprocessable_entity
    assert_equal "Invalid payouts", response.parsed_body["error"]
  end
end
