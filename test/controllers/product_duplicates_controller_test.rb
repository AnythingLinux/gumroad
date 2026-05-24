# frozen_string_literal: true

require "test_helper"

class ProductDuplicatesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @seller = users(:named_seller)
    @product = links(:named_seller_product)
    @admin = users(:admin_for_named_seller)
    sign_in @admin
    cookies.encrypted[:current_seller_id] = @seller.id
    @orig_protect = ActionController::Base.instance_method(:protect_against_forgery?)
    ActionController::Base.define_method(:protect_against_forgery?) { false }
    DuplicateProductWorker.jobs.clear
  end

  teardown do
    ActionController::Base.define_method(:protect_against_forgery?, @orig_protect) if @orig_protect
    # Clean up redis state used by ProductDuplicatorService between tests.
    ns = ProductDuplicatorService.const_get(:REDIS_STORAGE_NS)
    ns.del(@product.id)
    ns.del("error:#{@product.id}")
  end

  test "POST create returns 404 when id parameter is missing" do
    assert_raises(ActionController::RoutingError) { post :create }
  end

  test "POST create returns 404 when id is invalid" do
    assert_raises(ActionController::RoutingError) { post :create, params: { id: "invalid" } }
  end

  test "POST create returns success and flips is_duplicating" do
    post :create, params: { id: @product.unique_permalink }
    assert response.parsed_body["success"]
    assert @product.reload.is_duplicating
    refute response.parsed_body.key?("error_message")
  end

  test "POST create returns error when product is already duplicating" do
    @product.update!(is_duplicating: true)
    post :create, params: { id: @product.unique_permalink }
    body = response.parsed_body
    refute body["success"]
    assert_equal "Duplication in progress...", body["error_message"]
  end

  test "POST create queues DuplicateProductWorker" do
    post :create, params: { id: @product.unique_permalink }
    assert_equal 1, DuplicateProductWorker.jobs.size
    assert_equal [@product.id], DuplicateProductWorker.jobs.first["args"]
  end

  test "POST create raises 404 for non-owner user" do
    sign_out @admin
    sign_in users(:another_seller)
    cookies.encrypted[:current_seller_id] = users(:another_seller).id
    assert_raises(ActionController::RoutingError) do
      post :create, params: { id: @product.unique_permalink }
    end
  end

  test "GET show returns error when product is still duplicating" do
    @product.update!(is_duplicating: true)
    get :show, params: { id: @product.unique_permalink }
    body = response.parsed_body
    refute body["success"]
    assert_equal ProductDuplicatorService::DUPLICATING, body["status"]
    assert_equal "Duplication in progress...", body["error_message"]
  end

  test "GET show returns error when no recently duplicated and no error stored" do
    @product.update!(is_duplicating: false)
    get :show, params: { id: @product.unique_permalink }
    body = response.parsed_body
    refute body["success"]
    assert_equal ProductDuplicatorService::DUPLICATION_FAILED, body["status"]
    assert_nil body["error_message"]
  end

  test "GET show returns stored error message when duplication failed" do
    @product.update!(is_duplicating: false)
    ProductDuplicatorService.new(@product.id).store_duplication_error("Validation failed: Name can't be blank")
    get :show, params: { id: @product.unique_permalink }
    body = response.parsed_body
    refute body["success"]
    assert_equal ProductDuplicatorService::DUPLICATION_FAILED, body["status"]
    assert_equal "Validation failed: Name can't be blank", body["error_message"]
  end
end
