# frozen_string_literal: true

require "test_helper"
require "support/controller_seller_auth_helpers"

class Checkout::Upsells::ProductsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    @seller = users(:named_seller)
    sign_in_as_seller(@seller)
  end

  teardown { restore_protect_against_forgery! }

  test "GET index returns visible products as JSON array" do
    get :index
    assert_response :ok
    body = @response.parsed_body
    assert_kind_of Array, body
    permalinks = body.map { |p| p["permalink"] }
    # named_seller has fixture products
    assert_includes permalinks, links(:named_seller_product).unique_permalink
  end

  test "GET index returns an empty array when no seller is found" do
    sign_out @seller
    @request.cookie_jar.encrypted[:current_seller_id] = nil
    get :index
    assert_response :ok
    assert_equal [], @response.parsed_body
  end

  test "GET index returns an empty array when the query times out" do
    WithMaxExecutionTime.stub(:timeout_queries, ->(*_a, **_k) { raise WithMaxExecutionTime::QueryTimeoutError, "maximum statement execution time exceeded" }) do
      get :index
    end
    assert_response :ok
    assert_equal [], @response.parsed_body
  end

  test "GET show returns the requested visible product" do
    product = links(:named_seller_product)
    get :show, params: { id: product.external_id }
    assert_response :ok
    body = @response.parsed_body
    assert_equal product.external_id, body["id"]
    assert_equal product.unique_permalink, body["permalink"]
  end

  test "GET show raises ActiveRecord::RecordNotFound for non-existent product" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, params: { id: "non_existent_id" }
    end
  end

  test "GET show returns gateway_timeout when query times out" do
    product = links(:named_seller_product)
    WithMaxExecutionTime.stub(:timeout_queries, ->(*_a, **_k) { raise WithMaxExecutionTime::QueryTimeoutError, "maximum statement execution time exceeded" }) do
      get :show, params: { id: product.external_id }
    end
    assert_response :gateway_timeout
    assert_equal({ "error" => "Request timed out" }, @response.parsed_body)
  end
end
