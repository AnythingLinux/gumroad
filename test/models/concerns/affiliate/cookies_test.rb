# frozen_string_literal: true

require "test_helper"

class Affiliate::CookiesTest < ActiveSupport::TestCase
  setup do
    @affiliate = affiliates(:direct_affiliate_for_helper)
    @another_affiliate = affiliates(:widget_user_direct_affiliate)
  end

  # ---- instance methods ----

  test "#cookie_key generates cookie key with proper prefix and encrypted ID" do
    expected_key = "#{Affiliate::AFFILIATE_COOKIE_NAME_PREFIX}#{@affiliate.cookie_id}"
    assert_equal expected_key, @affiliate.cookie_key
  end

  test "#cookie_key generates different keys for different affiliates" do
    refute_equal @another_affiliate.cookie_key, @affiliate.cookie_key
  end

  test "#cookie_id returns encrypted ID without padding" do
    encrypted_id = @affiliate.cookie_id
    refute_includes encrypted_id, "="
    assert_predicate encrypted_id, :present?
  end

  test "#cookie_id can be decrypted back to original ID" do
    encrypted_id = @affiliate.cookie_id
    assert_equal @affiliate.id, ObfuscateIds.decrypt(encrypted_id)
  end

  test "#cookie_id generates deterministic IDs for the same affiliate" do
    assert_equal @affiliate.cookie_id, @affiliate.cookie_id
  end

  # ---- class methods ----

  test ".by_cookies returns affiliates found in cookies" do
    cookies = {
      @affiliate.cookie_key => Time.current.to_i.to_s,
      @another_affiliate.cookie_key => (Time.current - 1.hour).to_i.to_s,
      "_other_cookie" => "value",
      "_gumroad_guid" => "some-guid",
    }
    result = Affiliate.by_cookies(cookies)
    assert_equal [@affiliate, @another_affiliate].sort_by(&:id), result.sort_by(&:id)
  end

  test ".by_cookies ignores non-affiliate cookies" do
    cookies = {
      @affiliate.cookie_key => Time.current.to_i.to_s,
      @another_affiliate.cookie_key => (Time.current - 1.hour).to_i.to_s,
      "_random_cookie" => "value",
    }
    result = Affiliate.by_cookies(cookies)
    assert_equal [@affiliate, @another_affiliate].sort_by(&:id), result.sort_by(&:id)
  end

  test ".by_cookies returns empty when no affiliate cookies" do
    assert_empty Affiliate.by_cookies("_gumroad_guid" => "some-guid")
  end

  test ".by_cookies handles empty cookies hash" do
    assert_empty Affiliate.by_cookies({})
  end

  test ".by_cookies sorts affiliates by cookie recency (newest first)" do
    cookies = {
      @affiliate.cookie_key => Time.current.to_i.to_s,
      @another_affiliate.cookie_key => (Time.current - 1.hour).to_i.to_s,
    }
    result = Affiliate.by_cookies(cookies)
    assert_equal @affiliate, result.first
    assert_equal @another_affiliate, result.second
  end

  test ".ids_from_cookies extracts decrypted affiliate IDs" do
    cookies = {
      @affiliate.cookie_key => "1234567890",
      @another_affiliate.cookie_key => "0987654321",
      "_other_cookie" => "value",
    }
    result = Affiliate.ids_from_cookies(cookies)
    assert_equal [@affiliate.id, @another_affiliate.id].sort, result.sort
  end

  test ".ids_from_cookies sorts cookies by timestamp descending" do
    newer_time = Time.current.to_i
    older_time = (Time.current - 1.hour).to_i

    sorted_cookies = {
      @affiliate.cookie_key => older_time.to_s,
      @another_affiliate.cookie_key => newer_time.to_s,
    }
    result = Affiliate.ids_from_cookies(sorted_cookies)
    assert_equal @another_affiliate.id, result.first
    assert_equal @affiliate.id, result.second
  end

  test ".ids_from_cookies handles URL-encoded cookie names" do
    encoded_cookie_name = CGI.escape(@affiliate.cookie_key)
    cookies = { encoded_cookie_name => "1234567890" }
    assert_equal [@affiliate.id], Affiliate.ids_from_cookies(cookies)
  end

  test ".ids_from_cookies ignores non-affiliate cookies" do
    cookies = {
      @affiliate.cookie_key => "1234567890",
      "_random_cookie" => "value",
      "_gumroad_guid" => "guid-value",
    }
    assert_equal [@affiliate.id], Affiliate.ids_from_cookies(cookies)
  end

  test ".extract_cookie_id_from_cookie_name extracts cookie ID" do
    assert_equal @affiliate.cookie_id, Affiliate.extract_cookie_id_from_cookie_name(@affiliate.cookie_key)
  end

  test ".extract_cookie_id_from_cookie_name handles URL-encoded cookie names" do
    encoded_cookie_name = CGI.escape(@affiliate.cookie_key)
    assert_equal @affiliate.cookie_id, Affiliate.extract_cookie_id_from_cookie_name(encoded_cookie_name)
  end

  test ".decrypt_cookie_id decrypts encrypted cookie ID" do
    encrypted_id = @affiliate.cookie_id
    assert_equal @affiliate.id, Affiliate.decrypt_cookie_id(encrypted_id)
  end

  test ".decrypt_cookie_id handles both padded and unpadded base64 formats" do
    padded_id = ObfuscateIds.encrypt(@affiliate.id, padding: true)
    unpadded_id = ObfuscateIds.encrypt(@affiliate.id, padding: false)
    assert_equal @affiliate.id, Affiliate.decrypt_cookie_id(padded_id)
    assert_equal @affiliate.id, Affiliate.decrypt_cookie_id(unpadded_id)
  end

  test ".decrypt_cookie_id returns nil for invalid encrypted IDs" do
    assert_nil Affiliate.decrypt_cookie_id("invalid_id")
  end

  # ---- integration: full cookie workflow ----

  test "can set and read cookies for multiple affiliates" do
    cookies = {}
    cookies[@affiliate.cookie_key] = Time.current.to_i.to_s
    cookies[@another_affiliate.cookie_key] = (Time.current - 1.hour).to_i.to_s

    found = Affiliate.by_cookies(cookies)
    assert_equal [@affiliate, @another_affiliate].sort_by(&:id), found.sort_by(&:id)
  end

  test "handles legacy cookies with padding during migration" do
    old_cookie_key = "#{Affiliate::AFFILIATE_COOKIE_NAME_PREFIX}#{ObfuscateIds.encrypt(@affiliate.id, padding: true)}"
    new_cookie_key = @affiliate.cookie_key

    cookies = {
      old_cookie_key => (Time.current - 1.hour).to_i.to_s,
      new_cookie_key => Time.current.to_i.to_s,
    }
    found = Affiliate.by_cookies(cookies)
    assert_equal [@affiliate.id], found.map(&:id)
  end

  test "handles sorting with mismatched cookie formats without errors" do
    old_cookie_key = "#{Affiliate::AFFILIATE_COOKIE_NAME_PREFIX}#{ObfuscateIds.encrypt(@affiliate.id, padding: true)}"
    cookies = {
      old_cookie_key => 1.hour.ago.to_i.to_s,
      @another_affiliate.cookie_key => 2.hours.ago.to_i.to_s,
    }
    found = Affiliate.by_cookies(cookies)
    assert_equal [@affiliate.id, @another_affiliate.id].sort, found.map(&:id).sort
  end
end
