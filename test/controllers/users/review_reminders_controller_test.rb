# frozen_string_literal: true

require "test_helper"

class Users::ReviewRemindersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = users(:basic_user)
  end

  test "GET subscribe when logged in flips opted_out_of_review_reminders off" do
    @user.update!(opted_out_of_review_reminders: true)
    sign_in @user
    get :subscribe
    assert_response :success
    refute @user.reload.opted_out_of_review_reminders?
  end

  test "GET subscribe when not logged in redirects to login" do
    get :subscribe
    assert_redirected_to login_url(next: user_subscribe_review_reminders_path)
  end

  test "GET unsubscribe when logged in flips opted_out_of_review_reminders on" do
    @user.update!(opted_out_of_review_reminders: false)
    sign_in @user
    get :unsubscribe
    assert_response :success
    assert @user.reload.opted_out_of_review_reminders?
  end

  test "GET unsubscribe when not logged in redirects to login" do
    get :unsubscribe
    assert_redirected_to login_url(next: user_unsubscribe_review_reminders_path)
  end
end
