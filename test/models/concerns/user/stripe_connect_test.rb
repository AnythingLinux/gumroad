# frozen_string_literal: true

require "test_helper"

class User::StripeConnectTest < ActiveSupport::TestCase
  setup do
    # devise_pwned_password hits api.pwnedpasswords.com during User#save!; stub all ranges.
    WebMock.stub_request(:get, %r{api\.pwnedpasswords\.com/range/.*}).to_return(status: 200, body: "", headers: {})

    @data = {
      "provider" => "stripe_connect",
      "uid" => "acct_1MbJuNSAp3rt4s0F",
      "info" => {
        "name" => "Gum Bot",
        "email" => "bot@gum.co",
        "nickname" => "gumbot",
        "scope" => "read_write",
        "livemode" => false,
      },
      "extra" => {
        "extra_info" => {
          "id" => "acct_1MbJuNSAp3rt4s0F",
          "object" => "account",
          "country" => "IN",
          "created" => 1676363450,
          "default_currency" => "inr",
        },
      },
    }
  end

  # ---- .find_or_create_for_stripe_connect_account ----

  test "returns the user associated with the Stripe Connect account if one exists" do
    creator = users(:named_seller)
    MerchantAccount.create!(
      user: creator,
      charge_processor_id: "stripe",
      charge_processor_merchant_id: @data["uid"],
      country: "US",
      currency: "usd",
      charge_processor_alive_at: Time.current,
      json_data: { "meta" => { "stripe_connect" => "true" } }
    )

    assert_equal creator, User.find_or_create_for_stripe_connect_account(@data)
  end

  test "does not return a user or create one when email is already taken" do
    User.create!(
      email: @data["info"]["email"],
      password: SecureRandom.hex(10),
      confirmed_at: Time.current,
      user_risk_state: "not_reviewed",
      recommendation_type: User::RecommendationType::OWN_PRODUCTS
    )

    user_count_before = User.count
    compliance_count_before = UserComplianceInfo.count

    assert_nil User.find_or_create_for_stripe_connect_account(@data)
    assert_equal user_count_before, User.count
    assert_equal compliance_count_before, UserComplianceInfo.count
  end

  test "creates a new user account and sets email and country" do
    user_count_before = User.count
    compliance_count_before = UserComplianceInfo.count

    User.find_or_create_for_stripe_connect_account(@data)
    assert_equal user_count_before + 1, User.count
    assert_equal compliance_count_before + 1, UserComplianceInfo.count

    new_user = User.order(:id).last
    assert_equal @data["info"]["email"], new_user.email
    assert_equal Compliance::Countries.mapping[@data["extra"]["extra_info"]["country"]],
                 new_user.alive_user_compliance_info.country
    assert new_user.confirmed?
  end

  test "associates past purchases with the same email to the new user" do
    email = @data["info"]["email"]
    purchase1 = purchases(:auto_invoice_enabled_purchase)
    purchase2 = purchases(:auto_invoice_no_billing_purchase)
    purchase1.update_columns(email: email, purchaser_id: nil)
    purchase2.update_columns(email: email, purchaser_id: nil)

    # attach_to_user_and_card on a fixture purchase fails validation deep in the
    # save chain (fee_cents / fraud checks); stub it to the minimum useful behavior.
    original_attach = Purchase.instance_method(:attach_to_user_and_card)
    Purchase.define_method(:attach_to_user_and_card) do |usr, _ch, _cd|
      update_columns(purchaser_id: usr.id)
    end

    begin
      user = User.find_or_create_for_stripe_connect_account(@data)
      assert_equal "bot@gum.co", user.email
      assert_equal user.id, purchase1.reload.purchaser_id
      assert_equal user.id, purchase2.reload.purchaser_id
    ensure
      Purchase.define_method(:attach_to_user_and_card, original_attach)
    end
  end

  # ---- #has_brazilian_stripe_connect_account? ----

  test "#has_brazilian_stripe_connect_account? returns true for Brazilian Stripe Connect account" do
    user = users(:named_seller)
    merchant_account = MerchantAccount.create!(
      user: user,
      charge_processor_id: "stripe",
      charge_processor_merchant_id: "acct_br_test",
      country: Compliance::Countries::BRA.alpha2,
      currency: "usd",
      charge_processor_alive_at: Time.current,
      json_data: { "meta" => { "stripe_connect" => "true" } }
    )
    user.define_singleton_method(:merchant_account) { |_id| merchant_account }
    assert user.has_brazilian_stripe_connect_account?
  end

  test "#has_brazilian_stripe_connect_account? returns false for non-Brazilian Stripe Connect account" do
    user = users(:named_seller)
    merchant_account = MerchantAccount.create!(
      user: user,
      charge_processor_id: "stripe",
      charge_processor_merchant_id: "acct_us_test",
      country: Compliance::Countries::USA.alpha2,
      currency: "usd",
      charge_processor_alive_at: Time.current,
      json_data: { "meta" => { "stripe_connect" => "true" } }
    )
    user.define_singleton_method(:merchant_account) { |_id| merchant_account }
    refute user.has_brazilian_stripe_connect_account?
  end

  test "#has_brazilian_stripe_connect_account? returns false when user has no Stripe Connect merchant account" do
    user = users(:named_seller)
    user.define_singleton_method(:merchant_account) { |_id| nil }
    refute user.has_brazilian_stripe_connect_account?
  end
end
