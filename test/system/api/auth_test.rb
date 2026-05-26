# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../system_test_case"
require_relative "../checkout/checkout_page"
require_relative "../checkout/stripe_test_cards"


# API v2 authentication — Bearer tokens, OAuth, scope enforcement.
#
# See docs/test-slow-rewrite-tracker.md for the full cluster index.
class ApiAuthTest < SystemTests::SystemTestCase
  def setup
    super
    @cp = CheckoutPage.new(@page)
  end

  # Production-incident class: Auth broken; entire API down
  def test_api_v2_request_with_valid_bearer_succeeds
    skip "Scaffolding"
  end

  # Production-incident class: Invalid token accepted; auth bypass
  def test_api_v2_request_with_invalid_bearer_returns_401
    skip "Scaffolding"
  end

  # Production-incident class: Scope ignored; abuse vector
  def test_api_v2_request_without_scope_returns_403
    skip "Scaffolding"
  end

  # Production-incident class: Rate limit ignored; API DOSed
  def test_api_v2_rate_limit_returns_429_after_threshold
    skip "Scaffolding"
  end

  # Production-incident class: Expired token accepted; security gap
  def test_api_v2_expired_oauth_token_returns_401
    skip "Scaffolding"
  end
end
