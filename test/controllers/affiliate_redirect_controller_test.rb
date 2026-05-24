# frozen_string_literal: true

require "test_helper"

class AffiliateRedirectControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ControllerSellerAuthHelpers

  setup do
    boot_controller_test!
    @creator = users(:named_seller)
    @product = links(:named_seller_product)
    # direct_affiliate_for_helper: affiliate_user another_seller, seller=named_seller,
    # attached to named_seller_product via affiliates_links.
    @direct_affiliate = affiliates(:direct_affiliate_for_helper)
    sign_in @creator
  end

  teardown { restore_protect_against_forgery! }

  test "set_cookie_and_redirect does not append anything to the redirect URL when there are no URL params and no custom destination" do
    get :set_cookie_and_redirect, params: { affiliate_id: @direct_affiliate.external_id_numeric }
    assert response.redirect?
    refute_includes response.location, "affiliate_id="
  end

  test "set_cookie_and_redirect preserves query parameters and does not implicitly add affiliate_id when no custom destination" do
    get :set_cookie_and_redirect, params: { affiliate_id: @direct_affiliate.external_id_numeric, amir: "cool", you: "also_cool" }
    assert response.redirect?
    refute_includes response.location, "affiliate_id=#{@direct_affiliate.external_id_numeric}"
    assert response.location.end_with?("?amir=cool&you=also_cool")
  end

  test "set_cookie_and_redirect redirects to the product URL when no custom destination is set" do
    get :set_cookie_and_redirect, params: { affiliate_id: @direct_affiliate.external_id_numeric }
    assert_redirected_to @product.long_url
  end

  test "set_cookie_and_redirect appends affiliate_id when a custom destination URL is set" do
    @direct_affiliate.update_column(:destination_url, "https://gumroad.com/l/abc")
    @direct_affiliate.apply_to_all_products = true
    @direct_affiliate.save!(validate: false)
    get :set_cookie_and_redirect, params: { affiliate_id: @direct_affiliate.external_id_numeric }
    assert response.redirect?
    assert_equal "https://gumroad.com/l/abc?affiliate_id=#{@direct_affiliate.external_id_numeric}", response.location
  end

  test "set_cookie_and_redirect merges request and destination query params" do
    @direct_affiliate.update_column(:destination_url, "https://gumroad.com/l/abc?from=affiliate")
    @direct_affiliate.apply_to_all_products = true
    @direct_affiliate.save!(validate: false)
    get :set_cookie_and_redirect, params: { affiliate_id: @direct_affiliate.external_id_numeric, amir: "cool", you: "also_cool" }
    assert response.redirect?
    assert_equal "https://gumroad.com/l/abc?affiliate_id=#{@direct_affiliate.external_id_numeric}&amir=cool&from=affiliate&you=also_cool",
                 response.location
  end

  test "set_cookie_and_redirect strips whitespace in the destination URL" do
    @direct_affiliate.update_column(:destination_url, " https://example.gumroad.com/l/abc ")
    @direct_affiliate.apply_to_all_products = true
    @direct_affiliate.save!(validate: false)
    get :set_cookie_and_redirect, params: { affiliate_id: @direct_affiliate.external_id_numeric }
    assert response.redirect?
    assert_includes response.location, "example.gumroad.com"
  end
end
