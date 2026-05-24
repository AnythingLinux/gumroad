require "test_helper"

class LegacyPermalinkTest < ActiveSupport::TestCase
  setup do
    @product = links(:named_seller_product)
  end

  def build_permalink(attrs = {})
    LegacyPermalink.new({ product: @product, permalink: "abcd" }.merge(attrs))
  end

  test "product must be present" do
    assert_not build_permalink(product: nil).valid?
  end

  test "permalink must be present (nil)" do
    assert_not build_permalink(permalink: nil).valid?
  end

  test "permalink must be present (blank)" do
    assert_not build_permalink(permalink: "").valid?
  end

  test "permalink may contain letters" do
    assert build_permalink(permalink: "abcd").valid?
  end

  test "permalink may contain numbers" do
    assert build_permalink(permalink: "1234").valid?
  end

  test "permalink may contain underscores" do
    assert_equal true, build_permalink(permalink: "_").valid?
  end

  test "permalink may contain dashes" do
    assert_equal true, build_permalink(permalink: "-").valid?
  end

  test "permalink may not contain illegal characters" do
    assert_not build_permalink(permalink: ".&*!").valid?
  end

  test "permalink must be unique in a case-insensitive way" do
    LegacyPermalink.create!(product: @product, permalink: "custom")

    assert_not build_permalink(permalink: "custom").valid?
    assert_not build_permalink(permalink: "CUSTOM").valid?
  end
end
