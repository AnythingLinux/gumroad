# frozen_string_literal: true

require "test_helper"

class CallsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @seller = users(:named_seller)
    @admin = users(:admin_for_named_seller)
    @call = calls(:named_seller_call_product_call)
    sign_in_as_seller(@admin, @seller)
  end

  teardown { restore_protect_against_forgery! }

  test "PUT update updates the call and returns no content" do
    put :update, params: { id: @call.external_id, call_url: "https://zoom.us/j/thing" }, as: :json
    assert_response :success
    assert_response :no_content
    assert_equal "https://zoom.us/j/thing", @call.reload.call_url
  end

  test "PUT update raises RecordNotFound when call doesn't exist" do
    assert_raises(ActiveRecord::RecordNotFound) do
      put :update, params: { id: "non_existent_id" }
    end
  end
end
