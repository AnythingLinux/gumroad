# frozen_string_literal: true

require "test_helper"

class MediaLocationTest < ActiveSupport::TestCase
  setup do
    @url_redirect = url_redirects(:media_location_url_redirect)
    @purchase = purchases(:media_location_purchase)
    @product = links(:named_seller_product)
    @pdf = product_files(:media_location_pdf_file)
  end

  def build_location(attrs = {})
    MediaLocation.new({
      url_redirect_id: @url_redirect.id,
      purchase_id: @purchase.id,
      product_file_id: @pdf.id,
      product_id: @product.id,
      location: 1,
      platform: Platform::WEB,
    }.merge(attrs))
  end

  test "raises error if platform is invalid" do
    ml = build_location(platform: "invalid_platform")
    ml.validate
    assert_includes ml.errors.full_messages, "Platform is not included in the list"
  end

  test "raises error if product file is not consumable" do
    epub = product_files(:media_location_epub_file)
    ml = build_location(product_file_id: epub.id)
    ml.validate
    assert_includes ml.errors[:base], "File should be consumable"
  end

  test "infers correct units for readable" do
    ml = build_location
    ml.save
    assert_equal MediaLocation::Unit::PAGE_NUMBER, ml.unit
  end

  test "infers correct units for streamable" do
    video = product_files(:media_location_video_file)
    ml = build_location(product_file_id: video.id)
    ml.save
    assert_equal MediaLocation::Unit::SECONDS, ml.unit
  end

  test "infers correct units for listenable" do
    audio = product_files(:media_location_audio_file)
    ml = build_location(product_file_id: audio.id)
    ml.save
    assert_equal MediaLocation::Unit::SECONDS, ml.unit
  end

  test ".max_consumed_at_by_file returns the records with the largest consumed_at value for each product_file" do
    file_a = product_files(:media_location_consumed_pdf_a)
    file_b = product_files(:media_location_consumed_pdf_b)
    other_purchase = purchases(:media_location_other_purchase)

    expected_a = MediaLocation.create!(url_redirect_id: @url_redirect.id, purchase: @purchase, product_file: file_a,
                                       product_id: @product.id, location: 1, platform: Platform::WEB,
                                       consumed_at: 3.days.ago)
    MediaLocation.create!(url_redirect_id: @url_redirect.id, purchase: @purchase, product_file: file_a,
                          product_id: @product.id, location: 2, platform: Platform::WEB,
                          consumed_at: 7.days.ago)
    MediaLocation.create!(url_redirect_id: @url_redirect.id, purchase: @purchase, product_file: file_b,
                          product_id: @product.id, location: 3, platform: Platform::WEB,
                          consumed_at: 5.days.ago)
    expected_b = MediaLocation.create!(url_redirect_id: @url_redirect.id, purchase: @purchase, product_file: file_b,
                                       product_id: @product.id, location: 4, platform: Platform::WEB,
                                       consumed_at: 2.days.ago)
    # different purchase, should not appear
    MediaLocation.create!(url_redirect_id: @url_redirect.id, purchase: other_purchase, product_file: file_a,
                          product_id: @product.id, location: 5, platform: Platform::WEB,
                          consumed_at: 1.day.ago)

    result = MediaLocation.max_consumed_at_by_file(purchase_id: @purchase.id)
    assert_equal [expected_a, expected_b].sort_by(&:id), result.to_a.sort_by(&:id)
  end
end
