# frozen_string_literal: true

require "test_helper"

class Oauth::AuthorizationsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  teardown { restore_protect_against_forgery! }

  setup do
    @admin = users(:admin_user) # is_team_member flag set
    @user = users(:purchaser)
    @application = oauth_applications(:public_oauth_app)
    @redirect_uri = "http://gumroad.com/callback"
    @state = "seller-state"
    @code_verifier = "test-verifier-test-verifier-test-verifier-x"
    @code_challenge = AdminApiAuthorizationCode.code_challenge_for(@code_verifier)
    @oauth_params = {
      response_type: "code",
      client_id: @application.uid,
      redirect_uri: @redirect_uri,
      scope: "edit_products",
      state: @state,
      code_challenge: @code_challenge,
      code_challenge_method: "S256"
    }
    sign_in_as_seller(@admin)
  end

  def doc
    Nokogiri::HTML(response.body)
  end

  def redirect_query_params
    uri = URI.parse(response.location)
    Rack::Utils.parse_nested_query(uri.query)
  end

  test "GET new renders unchecked admin authorization checkbox for admin users when admin scope is optional" do
    get :new, params: @oauth_params.merge(admin_scope: "optional")
    assert_response :ok
    checkbox = doc.at_css("input[type='checkbox'][name='authorize_admin_operations']")
    admin_scope_field = doc.at_css("input[type='hidden'][name='admin_scope']")
    assert_includes doc.text, "Also authorize admin operations on this machine"
    assert checkbox
    assert_nil checkbox["checked"]
    assert_equal "optional", admin_scope_field["value"]
  end

  test "GET new does not render the admin authorization checkbox for non-admin users" do
    sign_in_as_seller(@user)
    get :new, params: @oauth_params.merge(admin_scope: "optional")
    refute_includes doc.text, "Also authorize admin operations on this machine"
    assert_nil doc.at_css("input[type='checkbox'][name='authorize_admin_operations']")
  end

  test "GET new does not change the existing authorization page when admin scope is absent" do
    get :new, params: @oauth_params
    assert_includes doc.text, "Authorize"
    refute_includes doc.text, "Also authorize admin operations on this machine"
    assert_nil doc.at_css("input[type='hidden'][name='admin_scope']")
  end

  test "POST create creates an admin authorization code when admin user opts in" do
    before_count = AdminApiAuthorizationCode.count
    post :create, params: @oauth_params.merge(admin_scope: "optional", authorize_admin_operations: "1")
    assert_equal before_count + 1, AdminApiAuthorizationCode.count

    rp = redirect_query_params
    code = AdminApiAuthorizationCode.last
    assert rp["code"].present?
    assert_equal @state, rp["state"]
    assert rp["admin_code"].present?
    assert_equal @admin, code.actor_user
    assert_equal @code_challenge, code.code_challenge
  end

  test "POST create redirects with the seller code only when admin user leaves admin authorization unchecked" do
    before_count = AdminApiAuthorizationCode.count
    post :create, params: @oauth_params.merge(admin_scope: "optional")
    assert_equal before_count, AdminApiAuthorizationCode.count
    rp = redirect_query_params
    assert rp["code"].present?
    assert_equal @state, rp["state"]
    refute rp.key?("admin_code")
  end

  test "POST create does not create an admin authorization code for non-admin users with tampered params" do
    sign_in_as_seller(@user)
    before_count = AdminApiAuthorizationCode.count
    post :create, params: @oauth_params.merge(admin_scope: "optional", authorize_admin_operations: "1")
    assert_equal before_count, AdminApiAuthorizationCode.count
    rp = redirect_query_params
    assert rp["code"].present?
    refute rp.key?("admin_code")
  end

  test "POST create keeps existing authorization behavior when admin scope is absent" do
    before_count = AdminApiAuthorizationCode.count
    post :create, params: @oauth_params.merge(authorize_admin_operations: "1")
    assert_equal before_count, AdminApiAuthorizationCode.count
    rp = redirect_query_params
    assert rp["code"].present?
    assert_equal @state, rp["state"]
    refute rp.key?("admin_code")
  end
end
