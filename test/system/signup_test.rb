# frozen_string_literal: true

require_relative "test_helper"

# Signup flow — drives the real /signup form rendered by React (Inertia).
# Vite builds the signup chunk on first request (autoBuild: true in
# config/vite.json).
#
# This test only covers the email+password happy path. The full signup
# controller can also accept card data + referral params, but those branches
# require Stripe + worker-side execution and aren't smoke-test material.
#
# Captcha: SystemTestCase enables the :disable_signup_recaptcha feature
# flag, which makes AuthPresenter return recaptcha_site_key: nil. The
# React form's handleSubmit skips recaptcha.execute() when the key is
# nil, so no Google JS gets loaded and the form POSTs directly. The
# server-side check (ValidateRecaptcha) already short-circuits to true
# in Rails.env.test?, so the controller accepts the request without a
# token. Matches how login already works in test.
#
# Selectors target type-based attributes (type="email"/type="password")
# because the React form components don't emit name= attributes — they
# track state via React's useForm hook, not via form-encoded POST fields.
class SignupTest < SystemTests::SystemTestCase
  def test_new_user_signs_up_successfully
    page.goto(url_for("/signup"))
    page.fill('input[type="email"]', "new-user-#{SecureRandom.hex(4)}@example.com")
    page.fill('input[type="password"]', "newpass-#{SecureRandom.hex(6)}!")
    page.click('button[type="submit"]')

    page.wait_for_load_state(state: "networkidle")
    refute_match %r{/signup\b}, page.url, "expected redirect away from /signup after successful signup, got #{page.url}"
  end

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
