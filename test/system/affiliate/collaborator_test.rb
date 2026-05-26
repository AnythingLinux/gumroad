# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Co-creator revenue split — collaborators receive % of every sale.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class CollaboratorTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Collaborator share invisible; payout missed
  def test_collaborator_invited_accepts_share_set
    skip "Scaffolding"
  end

  # Production-incident class: Share split wrong at payout; finance manual fix
  def test_collaborator_share_applied_at_payout_time
    skip "Scaffolding"
  end

  # Production-incident class: Removed collaborator still shares; double-payout
  def test_collaborator_removed_stops_future_shares
    skip "Scaffolding"
  end

  # Production-incident class: Pending collaborator receives share before accepting
  def test_pending_collaborator_does_not_receive_share
    skip "Scaffolding"
  end
end
