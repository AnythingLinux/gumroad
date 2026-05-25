# frozen_string_literal: true

require "test_helper"

class Bundles::ShareControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @seller = users(:named_seller)
    @admin = users(:admin_for_named_seller)
    @bundle = links(:bundle_update_products_bundle)
    sign_in @admin
    cookies.encrypted[:current_seller_id] = @seller.id
    @request.headers["X-Inertia"] = "true"
    @orig_protect = ActionController::Base.instance_method(:protect_against_forgery?)
    ActionController::Base.define_method(:protect_against_forgery?) { false }
  end

  teardown do
    ActionController::Base.define_method(:protect_against_forgery?, @orig_protect) if @orig_protect
  end

  test "GET edit renders Bundles/Share/Edit when bundle is published" do
    get :edit, params: { bundle_id: @bundle.external_id }
    assert_response :success
    page = JSON.parse(@response.body)
    assert_equal "Bundles/Share/Edit", page["component"]
    assert_equal @bundle.external_id, page["props"]["id"]
    assert_equal @bundle.unique_permalink, page["props"]["unique_permalink"]
    assert_equal @bundle.price_currency_type, page["props"]["currency_type"]
    assert_kind_of Array, page["props"]["bundle"]["products"]
    assert_kind_of Array, page["props"]["taxonomies"]
    assert_kind_of Array, page["props"]["profile_sections"]
  end

  test "GET edit redirects when bundle is unpublished" do
    @bundle.update!(draft: true)
    get :edit, params: { bundle_id: @bundle.external_id }
    assert_redirected_to edit_bundle_content_path(@bundle.external_id)
    assert_match(/publish your awesome product/, flash[:alert])
  end
end
