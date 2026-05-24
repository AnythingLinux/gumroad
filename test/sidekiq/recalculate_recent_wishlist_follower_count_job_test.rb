# frozen_string_literal: true

require "test_helper"

class RecalculateRecentWishlistFollowerCountJobTest < ActiveSupport::TestCase
  setup do
    @wishlist1 = wishlists(:named_seller_wishlist)
    @wishlist2 = wishlists(:basic_user_wishlist)
    @wishlist1.update_column(:recent_follower_count, 0)
    @wishlist2.update_column(:recent_follower_count, 0)
  end

  def add_followers(wishlist, count, created_at:)
    @user_pool ||= User.where.not(id: Wishlist.pluck(:user_id)).pluck(:id)
    raise "not enough users" if @user_pool.size < count
    used = @assigned ||= Hash.new { |h, k| h[k] = [] }
    count.times do
      uid = @user_pool.shift
      used[wishlist.id] << uid
      WishlistFollower.create!(
        wishlist: wishlist,
        follower_user_id: uid,
        created_at: created_at,
        updated_at: created_at
      )
    end
  end

  test "updates recent_follower_count for all wishlists based on followers from the last 30 days" do
    add_followers(@wishlist1, 3, created_at: 15.days.ago)
    add_followers(@wishlist2, 1, created_at: 20.days.ago)

    RecalculateRecentWishlistFollowerCountJob.new.perform

    assert_equal 3, @wishlist1.reload.recent_follower_count
    assert_equal 1, @wishlist2.reload.recent_follower_count
  end

  test "only counts followers created within the last 30 days" do
    add_followers(@wishlist1, 3, created_at: 15.days.ago)
    add_followers(@wishlist1, 2, created_at: 35.days.ago)
    add_followers(@wishlist2, 1, created_at: 20.days.ago)
    add_followers(@wishlist2, 4, created_at: 40.days.ago)

    RecalculateRecentWishlistFollowerCountJob.new.perform

    assert_equal 3, @wishlist1.reload.recent_follower_count
    assert_equal 1, @wishlist2.reload.recent_follower_count
  end

  test "handles wishlists with no recent followers" do
    add_followers(@wishlist1, 2, created_at: 31.days.ago)

    RecalculateRecentWishlistFollowerCountJob.new.perform

    assert_equal 0, @wishlist1.reload.recent_follower_count
  end
end
