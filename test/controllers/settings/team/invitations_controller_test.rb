# frozen_string_literal: true

require "test_helper"

class Settings::Team::InvitationsControllerTest < ActionController::TestCase
  tests Settings::Team::InvitationsController
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @seller = users(:named_seller)
    @admin = users(:admin_for_named_seller)
    sign_in_as_seller(@admin, @seller)
  end

  teardown { restore_protect_against_forgery! }

  # ----- POST create -----
  test "POST create with valid payload creates a team invitation" do
    delivered = []
    orig = TeamMailer.singleton_class.instance_method(:invite) if TeamMailer.singleton_class.method_defined?(:invite)
    TeamMailer.singleton_class.send(:define_method, :invite) do |inv|
      delivered << inv
      m = Object.new
      m.define_singleton_method(:deliver_later) { true }
      m
    end
    email = "member-#{SecureRandom.hex(4)}@example.com"
    begin
      assert_difference -> { @seller.team_invitations.count }, 1 do
        post :create, params: { team_invitation: { email:, role: "admin" } }, as: :json
      end
    ensure
      TeamMailer.singleton_class.send(:remove_method, :invite)
      TeamMailer.singleton_class.send(:define_method, :invite, orig) if orig
    end
    body = response.parsed_body
    assert_response :success
    assert_equal true, body["success"]
    inv = @seller.team_invitations.last
    assert_equal email, inv.email
    assert inv.role_admin?
    refute_nil inv.expires_at
    assert_equal 1, delivered.length
  end

  test "POST create with invalid payload returns error" do
    assert_no_difference -> { @seller.team_invitations.count } do
      post :create, params: { team_invitation: { email: "", role: "" } }, as: :json
    end
    body = response.parsed_body
    assert_response :success
    assert_equal false, body["success"]
    assert_includes body["error_message"], "Email is invalid"
    assert_includes body["error_message"], "Role is not included in the list"
  end

  # ----- PUT update -----
  test "PUT update updates role" do
    inv = @seller.team_invitations.create!(
      email: "ti-update-#{SecureRandom.hex(3)}@example.com",
      role: TeamMembership::ROLE_MARKETING,
      expires_at: 7.days.from_now,
    )
    put :update, params: { id: inv.external_id, team_invitation: { role: TeamMembership::ROLE_ADMIN } }, as: :json
    assert_response :success
    assert_equal true, response.parsed_body["success"]
    assert inv.reload.role_admin?
  end

  # ----- DELETE destroy -----
  test "DELETE destroy marks invitation deleted" do
    inv = @seller.team_invitations.create!(
      email: "ti-delete-#{SecureRandom.hex(3)}@example.com",
      role: TeamMembership::ROLE_MARKETING,
      expires_at: 7.days.from_now,
    )
    delete :destroy, params: { id: inv.external_id }, as: :json
    assert_response :success
    assert_equal true, response.parsed_body["success"]
    assert inv.reload.deleted?
  end

  test "DELETE destroy on another seller's record returns 404" do
    other = users(:another_seller)
    inv = other.team_invitations.create!(
      email: "ti-other-#{SecureRandom.hex(3)}@example.com",
      role: TeamMembership::ROLE_MARKETING,
      expires_at: 7.days.from_now,
    )
    delete :destroy, params: { id: inv.external_id }, as: :json
    assert_response :not_found
  end

  # ----- PUT restore -----
  test "PUT restore un-deletes invitation" do
    inv = @seller.team_invitations.create!(
      email: "ti-restore-#{SecureRandom.hex(3)}@example.com",
      role: TeamMembership::ROLE_MARKETING,
      expires_at: 7.days.from_now,
    )
    inv.update_as_deleted!
    assert inv.reload.deleted?
    put :restore, params: { id: inv.external_id }, as: :json
    assert_response :success
    assert_equal true, response.parsed_body["success"]
    refute inv.reload.deleted?
  end
end
