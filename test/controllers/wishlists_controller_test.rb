# frozen_string_literal: true

require "test_helper"

class WishlistsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = users(:basic_user)
    @user.update!(username: "basicuser") unless @user.username
    @wishlist = wishlists(:basic_user_wishlist)
    sign_in @user
    @request.headers["X-Inertia"] = "true"
    @request.host = "#{DOMAIN}"
    @orig_protect = ActionController::Base.instance_method(:protect_against_forgery?)
    ActionController::Base.define_method(:protect_against_forgery?) { false }
  end

  teardown do
    ActionController::Base.define_method(:protect_against_forgery?, @orig_protect) if @orig_protect
  end

  test "GET index html renders non-deleted wishlists for the current seller" do
    @wishlist.mark_deleted!
    alive = Wishlist.create!(user: @user, name: "Alive wishlist")
    Wishlist.create!(user: users(:named_seller), name: "Other user's wishlist")

    get :index
    assert_response :success
    page = JSON.parse(@response.body)
    assert_equal "Wishlists/Index", page["component"]
    ids = page["props"]["wishlists"].map { |w| w["id"] }
    assert_equal [alive.external_id], ids
  end

  test "GET index json returns wishlists with the given ids" do
    w2 = Wishlist.create!(user: @user, name: "Second")
    Wishlist.create!(user: @user, name: "Third")
    get :index, format: :json, params: { ids: [@wishlist.external_id, w2.external_id] }
    assert_response :success
    ids = response.parsed_body.map { |w| w["id"] }
    assert_equal [@wishlist.external_id, w2.external_id].sort, ids.sort
  end

  test "POST create json creates a wishlist with the given name" do
    assert_difference -> { Wishlist.count }, 1 do
      post :create, format: :json, params: { wishlist: { name: "My Favorite Products" } }
    end
    new_w = Wishlist.last
    assert_equal "My Favorite Products", new_w.name
    assert_equal @user, new_w.user
    assert_equal new_w.external_id, response.parsed_body["wishlist"]["id"]
    assert_equal "My Favorite Products", response.parsed_body["wishlist"]["name"]
  end

  test "POST create json returns 422 when name is blank" do
    assert_no_difference -> { Wishlist.count } do
      post :create, format: :json, params: { wishlist: { name: "" } }
    end
    assert_equal 422, response.status
  end

  test "POST create html creates a wishlist and redirects with notice" do
    assert_difference -> { Wishlist.count }, 1 do
      post :create, params: { wishlist: { name: "My Wishlist" } }
    end
    assert_redirected_to wishlists_path
    assert_equal "Wishlist created!", flash[:notice]
  end

  test "PUT update updates the wishlist name and description" do
    put :update, params: { id: @wishlist.external_id, wishlist: { name: "New Name", description: "New Desc" } }
    assert_redirected_to wishlists_path
    assert_equal "Wishlist updated!", flash[:notice]
    assert_equal "New Name", @wishlist.reload.name
    assert_equal "New Desc", @wishlist.description
  end

  test "PUT update with invalid params does not change name" do
    original = @wishlist.name
    put :update, params: { id: @wishlist.external_id, wishlist: { name: "" } }
    assert_redirected_to wishlists_path
    assert_equal 303, response.status
    assert_equal original, @wishlist.reload.name
  end

  test "DELETE destroy marks the wishlist and followers as deleted" do
    follower = WishlistFollower.create!(wishlist: @wishlist, follower_user: users(:named_seller))
    delete :destroy, params: { id: @wishlist.external_id }
    assert_redirected_to wishlists_path
    assert_equal "Wishlist deleted!", flash[:notice]
    assert @wishlist.reload.deleted?
    assert follower.reload.deleted?
  end
end
