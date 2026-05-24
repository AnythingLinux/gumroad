# frozen_string_literal: true

require "test_helper"

class Settings::Team::MembersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @seller = users(:named_seller)
    @admin = users(:admin_for_named_seller)
    sign_in @admin
    cookies.encrypted[:current_seller_id] = @seller.id
    @orig_protect = ActionController::Base.instance_method(:protect_against_forgery?)
    ActionController::Base.define_method(:protect_against_forgery?) { false }

    # Backfill self-owner memberships for any user being mutated (role / deletion / restore),
    # because TeamMembership has an `owner_membership_must_exist` validation that fires on save.
    @marketing_user = users(:marketing_for_named_seller)
    unless TeamMembership.where(user: @marketing_user, seller: @marketing_user, role: TeamMembership::ROLE_OWNER).exists?
      TeamMembership.create!(user: @marketing_user, seller: @marketing_user, role: TeamMembership::ROLE_OWNER)
    end
  end

  teardown do
    ActionController::Base.define_method(:protect_against_forgery?, @orig_protect) if @orig_protect
  end

  test "GET index returns http success" do
    get :index, as: :json
    assert_response :success
    assert response.parsed_body["success"]
    assert_kind_of Array, response.parsed_body["member_infos"]
  end

  test "PUT update updates role" do
    tm = team_memberships(:marketing_for_named_seller_membership)
    put :update, params: { id: tm.external_id, team_membership: { role: TeamMembership::ROLE_ADMIN } }, as: :json
    assert_response :success
    assert response.parsed_body["success"]
    assert tm.reload.role_admin?
  end

  test "DELETE destroy marks record as deleted" do
    tm = team_memberships(:marketing_for_named_seller_membership)
    delete :destroy, params: { id: tm.external_id }, as: :json
    assert_response :success
    assert response.parsed_body["success"]
    assert tm.reload.deleted?
  end

  test "DELETE destroy returns 404 for record belonging to other seller" do
    other_seller = users(:another_seller)
    other_member = users(:purchaser)
    # ensure owner membership exists for both
    [[other_seller, other_seller], [other_member, other_member]].each do |u, s|
      next if TeamMembership.where(user: u, seller: s, role: TeamMembership::ROLE_OWNER).exists?
      TeamMembership.create!(user: u, seller: s, role: TeamMembership::ROLE_OWNER)
    end
    foreign_tm = TeamMembership.create!(seller: other_seller, user: other_member, role: TeamMembership::ROLE_MARKETING)
    delete :destroy, params: { id: foreign_tm.external_id }, as: :json
    assert_equal 404, response.status
  end

  test "PATCH restore marks record as not deleted" do
    tm = team_memberships(:marketing_for_named_seller_membership)
    tm.update_as_deleted!
    assert tm.reload.deleted?
    put :restore, params: { id: tm.external_id }, as: :json
    assert_response :success
    assert response.parsed_body["success"]
    refute tm.reload.deleted?
  end
end
