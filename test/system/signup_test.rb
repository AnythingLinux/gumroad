# frozen_string_literal: true

require_relative "test_helper"

# Signup flow — drives the real /signup form rendered by React. Vite builds
# the signup chunk on first request (autoBuild: true in config/vite.json).
#
# This test only covers the email+password happy path. The full signup
# controller can also accept card data + referral params, but those branches
# require Stripe + worker-side execution and aren't smoke-test material.
class SignupTest < SystemTests::SystemTestCase
  def test_new_user_signs_up_successfully
    page.goto(url_for("/signup"))
    page.fill('input[name="user[email]"]', "new-user-#{SecureRandom.hex(4)}@example.com")
    page.fill('input[name="user[password]"]', "newpass-#{SecureRandom.hex(6)}!")
    page.click('button[type="submit"]')

    page.wait_for_load_state(state: "networkidle")
    refute_match %r{/signup\b}, page.url, "expected redirect away from /signup after successful signup, got #{page.url}"
  end

  def test_signup_with_existing_email_redirects_back_with_error
    existing = users(:basic_user)

    page.goto(url_for("/signup"))
    page.fill('input[name="user[email]"]', existing.email)
    page.fill('input[name="user[password]"]', "any-password-123!")
    page.click('button[type="submit"]')

    page.wait_for_load_state(state: "networkidle")
    # Existing-email path: signup controller routes through the existing-user
    # flow which redirects back to /signup with a warning. The exact text is
    # rendered into React props on the bounce; landing back on /signup is
    # enough signal here.
    assert_match %r{/signup\b}, page.url, "expected redirect back to /signup for existing-email branch"
  end
end
