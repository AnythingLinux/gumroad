# frozen_string_literal: true

require "test_helper"

class ModulesProductReviewStatTest < ActiveSupport::TestCase
  fixtures :users, :links, :purchases, :product_reviews, :product_review_stats

  setup do
    # Use a fresh product (no pre-existing reviews/stat) so we control the
    # aggregates. basic_user_product has no product_review_stat fixture.
    @product = links(:basic_user_product)
    @seller = @product.user
    @product_review_stat = nil
  end

  def make_purchase(rating: nil, **overrides)
    p = Purchase.new(
      seller: @seller,
      link: @product,
      email: "buyer-#{SecureRandom.hex(4)}@example.com",
      price_cents: 100,
      total_transaction_cents: 100,
      displayed_price_cents: 100,
      displayed_price_currency_type: "usd",
      fee_cents: 0,
      purchase_state: "successful",
      succeeded_at: Time.current,
      **overrides
    )
    p.save!(validate: false)
    p
  end

  def make_review(purchase, rating)
    ProductReview.create!(purchase:, link: @product, rating:)
  end

  test "#rating_stats returns defaults when no product_review_stat exists" do
    assert_nil @product.product_review_stat
    assert_equal({ count: 0, average: 0.0, percentages: [0, 0, 0, 0, 0] }, @product.rating_stats)
    assert_equal 0, @product.reviews_count
    assert_equal 0.0, @product.average_rating
    assert_equal({ 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }, @product.rating_counts)
  end

  test "#update_review_stat_via_rating_change adds a new rating and creates the stat" do
    purchase = make_purchase
    review = make_review(purchase, 4)

    # ProductReview's after_save fires update_review_stat_via_rating_change, so the
    # stat should already exist. Spot-check by inspecting the proxy values.
    stat = @product.reload.product_review_stat
    assert_not_nil stat
    assert_equal 1, stat.reviews_count
    assert_equal 4.0, stat.average_rating

    # Calling the module method directly is idempotent for an unchanged rating:
    # old=4 new=nil means "remove" — exercises the remove branch.
    @product.update_review_stat_via_rating_change(review.rating, nil)
    assert_equal 0, @product.reload.reviews_count
  end

  test "#sync_review_stat recomputes the stat from scratch" do
    p1 = make_purchase
    make_review(p1, 1)
    p2 = make_purchase
    make_review(p2, 3)
    p3 = make_purchase
    make_review(p3, 1)

    stat = @product.reload.product_review_stat
    # Mangle it
    stat.update_columns(
      reviews_count: 0,
      average_rating: 0,
      ratings_of_one_count: 0,
      ratings_of_three_count: 0,
    )

    @product.sync_review_stat
    stat.reload
    assert_equal 3, stat.reviews_count
    assert_equal ((1 + 3 + 1).to_f / 3).round(1), stat.average_rating
    assert_equal 2, stat.ratings_of_one_count
    assert_equal 1, stat.ratings_of_three_count
  end

  test "#sync_review_stat doesn't create a stat when there are no reviews" do
    assert_nil @product.product_review_stat
    @product.sync_review_stat
    assert_nil @product.reload.product_review_stat
  end

  test "#generate_review_stat_attributes returns zeroes when no reviews" do
    data = @product.generate_review_stat_attributes
    assert_equal 0, data[:reviews_count]
    assert_equal 0, data[:average_rating]
    assert_equal @product.id, data[:link_id]
  end

  test "#update_review_stat_via_purchase_changes is a no-op for blank changes" do
    purchase = make_purchase
    review = make_review(purchase, 2)
    before = @product.reload.product_review_stat.attributes

    @product.update_review_stat_via_purchase_changes({}, product_review: review)
    assert_equal before, @product.reload.product_review_stat.attributes
  end

  test "#update_review_stat_via_purchase_changes is a no-op when product_review is nil" do
    purchase = make_purchase
    make_review(purchase, 2)
    before = @product.reload.product_review_stat.attributes

    @product.update_review_stat_via_purchase_changes({ stripe_refunded: [false, true] }, product_review: nil)
    assert_equal before, @product.reload.product_review_stat.attributes
  end
end
