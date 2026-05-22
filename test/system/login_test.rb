# frozen_string_literal: true

require_relative "test_helper"

# Login flow — drives the real /login page, including the React form rendered
# by Vite (autoBuild: true in config/vite.json). No precompile step: Vite
# builds the login chunk on first request, caches on disk for the rest of the
# suite. First test in a fresh process is ~5-10s slower; the rest are fast.
class LoginTest < SystemTests::SystemTestCase
  PASSWORD = "test-password-123!"

  def test_existing_user_signs_in_successfully
    user = users(:basic_user)

    page.goto(url_for("/login"))
    page.fill('input[name="user[login_identifier]"]', user.email)
    page.fill('input[name="user[password]"]', PASSWORD)
    page.click('button[type="submit"]')

    # Login redirects to login_path_for(user); the post-login URL varies by
    # user state (seller vs buyer, has_published_products). Asserting we
    # didn't bounce back to /login is the simplest signal auth succeeded.
    page.wait_for_load_state(state: "networkidle")
    refute_match %r{/login\b}, page.url, "expected redirect away from /login on successful auth, got #{page.url}"
  end

  def test_wrong_password_redirects_back_to_login_with_error
    user = users(:basic_user)

    page.goto(url_for("/login"))
    page.fill('input[name="user[login_identifier]"]', user.email)
    page.fill('input[name="user[password]"]', "this-is-not-the-password")
    page.click('button[type="submit"]')

    page.wait_for_load_state(state: "networkidle")
    assert_match %r{/login\b}, page.url, "expected redirect back to /login on bad password"
  end
end
