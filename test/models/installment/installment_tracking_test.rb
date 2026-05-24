# frozen_string_literal: true

require "test_helper"

class InstallmentTrackingTest < ActiveSupport::TestCase
  setup do
    @installment = installments(:pcp_post)
    Rails.cache.clear
    CreatorEmailClickSummary.where(installment_id: @installment.id).delete_all
    CreatorEmailOpenEvent.where(installment_id: @installment.id).delete_all
  end

  teardown do
    Rails.cache.clear
    CreatorEmailClickSummary.where(installment_id: @installment.id).delete_all
    CreatorEmailOpenEvent.where(installment_id: @installment.id).delete_all
  end

  test "click_summary converts encoded urls back into human-readable format" do
    CreatorEmailClickSummary.create!(
      installment_id: @installment.id,
      total_unique_clicks: 2,
      urls: { "https://www&#46;gumroad&#46;com" => 1, "https://www&#46;google&#46;com" => 2 }
    )
    assert_equal({ "google.com" => 2, "gumroad.com" => 1 }, @installment.clicked_urls)
  end

  test "#click_rate_percent computes the click rate correctly" do
    @installment.update_column(:customer_count, 4)
    CreatorEmailClickSummary.create!(
      installment_id: @installment.id,
      total_unique_clicks: 2,
      urls: { "https://www&#46;gumroad&#46;com" => 2, "https://www&#46;google&#46;com" => 1 }
    )
    assert_equal 50.0, @installment.click_rate_percent
  end

  test "#unique_click_count returns 0 if there have been no clicks" do
    @installment.update_column(:customer_count, 4)
    assert_equal 0, @installment.unique_click_count
  end

  test "#unique_click_count returns the correct number of clicks" do
    @installment.update_column(:customer_count, 4)
    CreatorEmailClickSummary.create!(
      installment_id: @installment.id,
      total_unique_clicks: 2,
      urls: { "https://www&#46;gumroad&#46;com" => 2, "https://www&#46;google&#46;com" => 1 }
    )
    assert_equal 2, @installment.unique_click_count
  end

  test "#unique_click_count does not hit CreatorEmailClickSummary model once the cache is set" do
    @installment.update_column(:customer_count, 4)
    CreatorEmailClickSummary.create!(
      installment_id: @installment.id,
      total_unique_clicks: 4,
      urls: { "https://www&#46;gumroad&#46;com" => 2, "https://www&#46;google&#46;com" => 1 }
    )
    # Read once to seed the cache.
    @installment.unique_click_count

    queried = false
    CreatorEmailClickSummary.stub(:where, ->(*args, **kw) {
      queried = true if (kw[:installment_id] == @installment.id) || (args.first.is_a?(Hash) && args.first[:installment_id] == @installment.id)
      CreatorEmailClickSummary.unscoped
    }) do
      assert_equal 4, @installment.unique_click_count
    end
    refute queried, "expected cache hit, but CreatorEmailClickSummary.where was called"
  end

  test "#unique_open_count does not hit CreatorEmailOpenEvent model once the cache is set" do
    @installment.update_column(:customer_count, 4)
    3.times { CreatorEmailOpenEvent.create!(installment_id: @installment.id) }
    @installment.unique_open_count

    queried = false
    CreatorEmailOpenEvent.stub(:where, ->(*args, **kw) {
      queried = true if (kw[:installment_id] == @installment.id) || (args.first.is_a?(Hash) && args.first[:installment_id] == @installment.id)
      CreatorEmailOpenEvent.unscoped
    }) do
      assert_equal 3, @installment.unique_open_count
    end
    refute queried, "expected cache hit, but CreatorEmailOpenEvent.where was called"
  end
end
