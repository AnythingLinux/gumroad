# frozen_string_literal: true

require "test_helper"

class InviteTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "#invitation_sent returns only records with state invitation_sent" do
    sent = invites(:invite_test_sent)
    signed_up = invites(:invite_test_signed_up)
    ids = [sent.id, signed_up.id]
    assert_equal [sent.id], Invite.invitation_sent.where(id: ids).pluck(:id)
  end

  test "#signed_up returns only records with state signed_up" do
    sent = invites(:invite_test_sent)
    signed_up = invites(:invite_test_signed_up)
    ids = [sent.id, signed_up.id]
    assert_equal [signed_up.id], Invite.signed_up.where(id: ids).pluck(:id)
  end

  test "#mark_signed_up transitions state and enqueues notification mail" do
    invite = invites(:invite_test_sent)
    invited = users(:collaborating_user)
    invite.update!(receiver_id: invited.id, receiver_email: invited.email)

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob, queue: "default") do
      assert invite.mark_signed_up
    end
    assert invite.reload.signed_up?
  end

  test "#invite_state_text returns the correct text per state" do
    invite = Invite.new(invite_state: "invitation_sent")
    assert_equal "Invitation sent", invite.invite_state_text
    invite.invite_state = "signed_up"
    assert_equal "Signed up!", invite.invite_state_text
  end
end
