require "test_helper"

class TeamInvitationTest < ActiveSupport::TestCase
  setup do
    @seller = users(:named_seller)
  end

  # validations

  test "requires seller, email, role to be present" do
    team_invitation = TeamInvitation.new
    assert_not team_invitation.valid?
    assert_includes team_invitation.errors.full_messages, "Seller must exist"
    assert_includes team_invitation.errors.full_messages, "Email is invalid"
    assert_includes team_invitation.errors.full_messages, "Role is not included in the list"
  end

  test "validates uniqueness for seller and email when the record is alive" do
    team_invitation = team_invitations(:team_invitation_to_member)
    dupe = team_invitation.dup
    assert_not dupe.valid?
    assert_includes dupe.errors.full_messages, "Email has already been invited"
  end

  test "validates email against active team membership" do
    membership_user = users(:accountant_for_named_seller)
    team_invitation = TeamInvitation.new(seller: @seller, role: TeamMembership::ROLE_ADMIN, email: membership_user.email)
    assert_not team_invitation.valid?
    assert_includes team_invitation.errors.full_messages, "Email is associated with an existing team member"
  end

  test "validates email against owner's email" do
    team_invitation = TeamInvitation.new(seller: @seller, role: TeamMembership::ROLE_ADMIN, email: @seller.email)
    assert_not team_invitation.valid?
    assert_includes team_invitation.errors.full_messages, "Email is associated with an existing team member"
  end

  test "sanitizes email" do
    team_invitation = TeamInvitation.new(email: " Member@Example.com  ")
    team_invitation.validate
    assert_equal "member@example.com", team_invitation.email
  end

  test "allows creating a new record with same email when previous is deleted" do
    deleted_invitation = team_invitations(:team_invitation_to_member)
    deleted_invitation.update_as_deleted!
    assert_difference -> { TeamInvitation.count }, 1 do
      TeamInvitation.create!(
        seller: @seller,
        role: TeamMembership::ROLE_ADMIN,
        email: deleted_invitation.email,
        expires_at: TeamInvitation::ACTIVE_INTERVAL_IN_DAYS.days.from_now,
      )
    end
  end

  # #expired?

  test "#expired? returns appropriate boolean value" do
    team_invitation = team_invitations(:team_invitation_to_member)
    assert_not team_invitation.expired?
    team_invitation.expires_at = Time.current
    assert team_invitation.expired?
  end

  # #from_gumroad_account?

  test "#from_gumroad_account? returns false when seller is not the gumroad account" do
    team_invitation = team_invitations(:team_invitation_to_member)
    assert_not team_invitation.from_gumroad_account?
  end

  test "#from_gumroad_account? returns true when seller is the gumroad account" do
    team_invitation = team_invitations(:team_invitation_to_member)
    team_invitation.seller.stub(:gumroad_account?, true) do
      assert team_invitation.from_gumroad_account?
    end
  end
end
