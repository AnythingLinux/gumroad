# frozen_string_literal: true

require "test_helper"

class Discover::SearchAutocompleteControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @user = users(:purchaser)
    @browser_guid = "custom_guid"
    boot_controller_test!
  end

  teardown { restore_protect_against_forgery! }

  def create_search_with_suggestion(user: nil, browser_guid: nil, query:)
    s = DiscoverSearch.create!(user: user, browser_guid: browser_guid, query: query)
    DiscoverSearchSuggestion.create!(discover_search: s)
  end

  test "delete_search_suggestion removes the suggestion for the signed-in user" do
    sign_in_as_seller(@user)
    suggestion = create_search_with_suggestion(user: @user, query: "test query")
    refute suggestion.deleted?
    delete :delete_search_suggestion, params: { query: "test query" }
    assert_response :no_content
    assert suggestion.reload.deleted?
  end

  test "delete_search_suggestion removes the suggestion for the browser_guid when not signed in" do
    suggestion = create_search_with_suggestion(browser_guid: @browser_guid, query: "test query")
    @request.cookies[:_gumroad_guid] = @browser_guid
    delete :delete_search_suggestion, params: { query: "test query" }
    assert_response :no_content
    assert suggestion.reload.deleted?
  end

  test "delete_search_suggestion does not remove suggestions for other users or browser_guids" do
    other_user = users(:basic_user)
    other_guid = "other_guid"
    user_suggestion = create_search_with_suggestion(user: other_user, query: "test query")
    guid_suggestion = create_search_with_suggestion(browser_guid: other_guid, query: "test query")
    delete :delete_search_suggestion, params: { query: "test query" }
    refute user_suggestion.reload.deleted?
    refute guid_suggestion.reload.deleted?
  end
end
