# frozen_string_literal: true

require "test_helper"

class Wishlists::FollowersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = users(:basic_user)
    @wishlist = wishlists(:named_seller_wishlist)
    sign_in @user
    Feature.activate(:follow_wishlists)
    @orig_protect = ActionController::Base.instance_method(:protect_against_forgery?)
    ActionController::Base.define_method(:protect_against_forgery?) { false }
  end

  teardown do
    ActionController::Base.define_method(:protect_against_forgery?, @orig_protect) if @orig_protect
    Feature.deactivate(:follow_wishlists)
  end

  test "POST create follows the wishlist" do
    assert_equal 0, @wishlist.wishlist_followers.count
    post :create, params: { wishlist_id: @wishlist.external_id }
    assert_response :created
    assert_equal 1, @wishlist.wishlist_followers.count
    assert_equal @user, @wishlist.wishlist_followers.first.follower_user
  end

  test "POST create returns an error if the follower is invalid" do
    WishlistFollower.create!(wishlist: @wishlist, follower_user: @user)
    post :create, params: { wishlist_id: @wishlist.external_id }
    assert_equal 422, response.status
    assert_equal "Follower user is already following this wishlist.", response.parsed_body["error"]
  end

  test "POST create returns 404 when feature flag is off" do
    Feature.deactivate(:follow_wishlists)
    assert_raises(ActionController::RoutingError) do
      post :create, params: { wishlist_id: @wishlist.external_id }
    end
  end

  test "DELETE destroy deletes the follower" do
    follower = WishlistFollower.create!(wishlist: @wishlist, follower_user: @user)
    delete :destroy, params: { wishlist_id: @wishlist.external_id }
    assert follower.reload.deleted?
  end

  test "DELETE destroy returns 404 if the user is not following" do
    follower = WishlistFollower.create!(wishlist: @wishlist, follower_user: @user)
    follower.mark_deleted!
    assert_raises(ActionController::RoutingError) do
      delete :destroy, params: { wishlist_id: @wishlist.external_id }
    end
  end

  test "DELETE destroy returns 404 when feature flag is off" do
    Feature.deactivate(:follow_wishlists)
    assert_raises(ActionController::RoutingError) do
      delete :destroy, params: { wishlist_id: @wishlist.external_id }
    end
  end

  test "GET unsubscribe deletes the follower and redirects to the wishlist" do
    follower = WishlistFollower.create!(wishlist: @wishlist, follower_user: @user)
    get :unsubscribe, params: { wishlist_id: @wishlist.external_id, follower_id: follower.external_id }
    assert_redirected_to wishlist_url(@wishlist.url_slug, host: @wishlist.user.subdomain_with_protocol)
    assert follower.reload.deleted?
  end
end
