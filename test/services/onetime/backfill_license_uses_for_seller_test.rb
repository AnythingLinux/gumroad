# frozen_string_literal: true

require "test_helper"

class OnetimeBackfillLicenseUsesForSellerTest < ActiveSupport::TestCase
  setup do
    @seller = users(:named_seller)
    @product = links(:named_seller_product)
    # Wipe any pre-existing successful licensed purchases for this seller so the
    # baseline is deterministic.
    License.joins(:purchase).where(purchases: { seller_id: @seller.id }).delete_all
    # also wipe basic_user_product's pre-existing licenses to keep the other-seller test deterministic
    bp = links(:basic_user_product)
    License.joins(:purchase).where(purchases: { seller_id: bp.user_id }).delete_all
  end

  def make_purchase(seller:, product:, state: "successful")
    p = Purchase.new(
      seller: seller,
      link: product,
      email: "lic-#{SecureRandom.hex(4)}@example.com",
      price_cents: 0,
      total_transaction_cents: 0,
      displayed_price_cents: 0,
      displayed_price_currency_type: "usd",
      purchase_state: state,
      fee_cents: 0,
      succeeded_at: Time.current,
    )
    p.save!(validate: false)
    p
  end

  def make_license(product:, purchase:)
    License.create!(link: product, purchase: purchase)
  end

  def update_jobs
    ElasticsearchIndexerWorker.jobs.select { |job| job["args"][0] == "update" }
  end

  test "enqueues a partial update for each of the seller's successful purchases with a license" do
    p1 = make_purchase(seller: @seller, product: @product)
    make_license(product: @product, purchase: p1)
    p2 = make_purchase(seller: @seller, product: @product)
    make_license(product: @product, purchase: p2)
    ElasticsearchIndexerWorker.jobs.clear

    Onetime::BackfillLicenseUsesForSeller.new(seller: @seller).process

    ids = update_jobs.map { |j| j["args"][1]["record_id"] }
    assert_equal [p1.id, p2.id].sort, ids.sort
    update_jobs.each do |job|
      assert_equal "update", job["args"][0]
      assert_equal "Purchase", job["args"][1]["class_name"]
      assert_equal ["license_uses"], job["args"][1]["fields"]
    end
  end

  test "ignores purchases that belong to other sellers" do
    mine = make_purchase(seller: @seller, product: @product)
    make_license(product: @product, purchase: mine)
    other_product = links(:basic_user_product)
    other_seller = other_product.user
    op = make_purchase(seller: other_seller, product: other_product)
    make_license(product: other_product, purchase: op)
    ElasticsearchIndexerWorker.jobs.clear

    Onetime::BackfillLicenseUsesForSeller.new(seller: @seller).process

    ids = update_jobs.map { |j| j["args"][1]["record_id"] }
    assert_equal [mine.id], ids
  end

  test "ignores purchases without a license" do
    make_purchase(seller: @seller, product: @product)
    ElasticsearchIndexerWorker.jobs.clear

    Onetime::BackfillLicenseUsesForSeller.new(seller: @seller).process

    assert_empty update_jobs
  end

  test "ignores purchases that are not in a success state" do
    p = make_purchase(seller: @seller, product: @product, state: "failed")
    make_license(product: @product, purchase: p)
    ElasticsearchIndexerWorker.jobs.clear

    Onetime::BackfillLicenseUsesForSeller.new(seller: @seller).process

    assert_empty update_jobs
  end
end
