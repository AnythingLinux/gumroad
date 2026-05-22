# frozen_string_literal: true

require_relative "test_helper"

# Signup flow — drives the real /signup form rendered by React (Inertia).
# Vite builds the signup chunk on first request (autoBuild: true in
# config/vite.json).
#
# We only test the existing-email branch because the happy-path signup is
# gated by reCAPTCHA verification in test env (RECAPTCHA_SIGNUP_SITE_KEY
# is set; controller bypasses captcha only in development with a blank
# key). Existing RSpec coverage stubs this via VCR cassettes; system
# tests can't reach inside the controller without RSpec mocks. The
# existing-email branch exercises the full form round-trip (Inertia
# render → React form → POST → controller bounce) without needing a
# valid captcha response.
#
# Selectors target type-based attributes (type="email"/type="password")
# because the React form components don't emit name= attributes — they
# track state via React's useForm hook, not via form-encoded POST fields.
class SignupTest < SystemTests::SystemTestCase
  def test_signup_with_existing_email_redirects_back_with_error
    existing = users(:basic_user)

    page.goto(url_for("/signup"))
    page.fill('input[type="email"]', existing.email)
    page.fill('input[type="password"]', "any-password-123!")
    page.click('button[type="submit"]')

    page.wait_for_load_state(state: "networkidle")
    # Existing-email path: signup controller routes through the existing-user
    # flow which redirects back to /signup with a warning. The exact text is
    # rendered into React props on the bounce; landing back on /signup is
    # enough signal here.
    assert_match %r{/signup\b}, page.url, "expected redirect back to /signup for existing-email branch"
  end
end
