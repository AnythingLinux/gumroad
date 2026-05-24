# frozen_string_literal: true

require "test_helper"

class ModulesUserPostsTest < ActiveSupport::TestCase
  # The full RSpec suite exercises #visible_posts_for across the seller/follower/
  # buyer/affiliate matrix using factory-built purchases, followers, affiliates,
  # subscriptions and product/variant filters. Reproducing that branching matrix
  # in YAML fixtures is over the 5-table threshold and unstable without the
  # per-test create timestamps. The simpler branches are pinned down here:
  #   * #last_5_created_posts ordering + limit (trivial)
  #   * #visible_posts_for seller-self branch (seller looking at their own posts)
  #   * #visible_posts_for shown_on_profile filtering for the seller branch

  fixtures :users, :installments

  setup do
    @seller = users(:named_seller)
  end

  test "#last_5_created_posts returns at most 5 installments, newest first" do
    posts = @seller.last_5_created_posts
    assert_operator posts.count, :<=, 5
    times = posts.map(&:created_at)
    assert_equal times, times.sort.reverse, "expected newest-first ordering"
  end

  test "#last_5_created_posts only includes the seller's own installments" do
    @seller.last_5_created_posts.each do |post|
      assert_equal @seller.id, post.seller_id
    end
  end

  test "#visible_posts_for returns the seller's alive non-workflow installments when viewing as the seller" do
    pundit_user = SellerContext.new(user: @seller, seller: @seller)

    posts = @seller.visible_posts_for(pundit_user:, shown_on_profile: false)

    # Should exclude workflow installments (workflow_id IS NULL constraint via not_workflow_installment)
    assert posts.none? { |p| p.workflow_id.present? },
           "expected workflow posts to be excluded, got: #{posts.map { |p| [p.name, p.workflow_id] }.inspect}"

    # Should exclude soft-deleted installments
    assert posts.none?(&:deleted?),
           "expected deleted posts to be excluded, got: #{posts.map { |p| [p.name, p.deleted_at] }.inspect}"
  end

  test "#visible_posts_for with shown_on_profile=true filters to profile-visible posts" do
    pundit_user = SellerContext.new(user: @seller, seller: @seller)

    posts_on_profile = @seller.visible_posts_for(pundit_user:, shown_on_profile: true)
    posts_all       = @seller.visible_posts_for(pundit_user:, shown_on_profile: false)

    assert_operator posts_on_profile.count, :<=, posts_all.count

    # Every profile-visible post should have shown_on_profile? truthy
    posts_on_profile.each do |post|
      assert post.shown_on_profile?, "expected #{post.name.inspect} to be shown_on_profile"
    end
  end

  test "#visible_posts_for from a viewer with no relationship returns only public audience posts" do
    other = users(:basic_user) # not seller, not a follower/buyer/affiliate
    pundit_user = SellerContext.new(user: other, seller: nil)

    posts = @seller.visible_posts_for(pundit_user:)

    # All returned posts should be audience-type, alive, published, and shown_on_profile
    posts.each do |post|
      assert_equal Installment::AUDIENCE_TYPE, post.installment_type
      assert_not post.deleted?
      assert_not_nil post.published_at
      assert post.shown_on_profile?
    end
  end
end
