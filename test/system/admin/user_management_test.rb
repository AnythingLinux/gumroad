# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# Admin user actions — search, view, suspend, reinstate, impersonate.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class AdminUserManagementTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Search broken; support paralyzed
  def test_admin_search_user_by_email_finds_match
    skip "Scaffolding"
  end

  # Production-incident class: Suspend leaves loopholes
  def test_admin_suspend_user_blocks_login_and_payouts
    skip "Scaffolding"
  end

  # Production-incident class: Reinstate doesn't restore payouts
  def test_admin_reinstate_user_restores_access
    skip "Scaffolding"
  end

  # Production-incident class: Impersonation untracked; abuse vector
  def test_admin_impersonate_user_logs_audit_trail
    skip "Scaffolding"
  end

  # Production-incident class: Risk queue broken; reviews backlog
  def test_admin_view_unreviewed_users_filters_correctly
    skip "Scaffolding"
  end
end
