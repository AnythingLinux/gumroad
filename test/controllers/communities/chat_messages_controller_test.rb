# frozen_string_literal: true

require "test_helper"
require "support/controller_seller_auth_helpers"

class Communities::ChatMessagesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @seller = users(:named_seller)
    @seller.save! if @seller.external_id.blank?
    sign_in_as_seller(@seller)
    Feature.activate_user(:communities, @seller)
    @community = communities(:named_seller_product_community)
  end

  teardown { restore_protect_against_forgery! }

  test "POST create raises RecordNotFound when community is not found" do
    assert_raises(ActiveRecord::RecordNotFound) do
      post :create, params: { community_id: "nonexistent", community_chat_message: { content: "Hello" } }
    end
  end

  test "POST create redirects to dashboard when :communities flag is disabled" do
    Feature.deactivate_user(:communities, @seller)
    post :create, params: { community_id: @community.external_id, community_chat_message: { content: "Hello" } }
    assert_redirected_to dashboard_path
    assert_equal "You are not allowed to perform this action.", flash[:alert]
  end

  test "POST create creates a new message" do
    assert_difference -> { CommunityChatMessage.count }, 1 do
      post :create, params: {
        community_id: @community.external_id,
        community_chat_message: { content: "Hello, community!" }
      }
    end
    assert_redirected_to community_path(@seller.external_id, @community.external_id)
    msg = CommunityChatMessage.last
    assert_equal "Hello, community!", msg.content
    assert_equal @seller, msg.user
    assert_equal @community, msg.community
  end

  test "POST create with invalid content redirects without creating a message" do
    assert_no_difference -> { CommunityChatMessage.count } do
      post :create, params: { community_id: @community.external_id, community_chat_message: { content: "" } }
    end
    assert_redirected_to community_path(@seller.external_id, @community.external_id)
  end
end
