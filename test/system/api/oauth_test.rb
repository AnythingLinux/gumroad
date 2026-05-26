# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# OAuth application registration + authorization code flow.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class OauthTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Registration broken; partner integrations blocked
  def test_oauth_app_register_creates_client_id_secret
    skip "Scaffolding"
  end

  # Production-incident class: Code missing; auth flow broken
  def test_oauth_authorize_redirect_includes_code
    skip "Scaffolding"
  end

  # Production-incident class: Exchange broken; partner can't connect
  def test_oauth_token_exchange_returns_access_token
    skip "Scaffolding"
  end

  # Production-incident class: Refresh broken; partner re-auth churn
  def test_oauth_token_refresh_extends_session
    skip "Scaffolding"
  end

  # Production-incident class: Revoke does nothing; security gap
  def test_oauth_revoke_invalidates_token
    skip "Scaffolding"
  end
end
