require "test_helper"

class SelfServiceAffiliateProductTest < ActiveSupport::TestCase
  setup do
    @creator = users(:named_seller)
    @product = links(:ssap_product_1)
  end

  def build_record(**attrs)
    SelfServiceAffiliateProduct.new({
      seller: @creator,
      product: @product,
      affiliate_basis_points: 500,
    }.merge(attrs))
  end

  # validations

  test "validates without any error" do
    assert build_record.valid?
  end

  test "validates presence of attributes" do
    record = SelfServiceAffiliateProduct.new
    assert_not record.valid?
    assert_equal(
      { seller: ["can't be blank"], product: ["can't be blank"] },
      record.errors.messages,
    )
  end

  test "validates presence of affiliate_basis_points when enabled" do
    record = SelfServiceAffiliateProduct.new(enabled: true)
    assert_not record.valid?
    assert_equal(
      {
        seller: ["can't be blank"],
        product: ["can't be blank"],
        affiliate_basis_points: ["can't be blank"],
      },
      record.errors.messages,
    )
  end

  test "validates affiliate_basis_points is in valid range" do
    record = build_record(enabled: true, affiliate_basis_points: 76)
    assert_not record.valid?
    assert_equal "Affiliate commission must be between 1% and 75%.", record.errors.full_messages.first
  end

  test "validates destination url format" do
    record = build_record(destination_url: "invalid-url")
    assert_not record.valid?
    assert_equal "The destination url you entered is invalid.", record.errors.full_messages.first
  end

  test "validates that the product is not a collab when enabled" do
    collab_product = links(:ssap_collab_product)
    record = build_record(product: collab_product, enabled: true)
    assert_not record.valid?
    assert_equal ["Collab products cannot have affiliates"], record.errors.full_messages
  end

  test "does not validate that the product is not a collab when disabled" do
    collab_product = links(:ssap_collab_product)
    record = build_record(product: collab_product, enabled: false)
    assert record.valid?
  end

  test "validates that the product's creator is same as the seller" do
    foreign_product = links(:another_seller_product)
    record = build_record(product: foreign_product)
    assert_not record.valid?
    assert_equal(
      ["The product '#{foreign_product.name}' does not belong to you (#{@creator.email})."],
      record.errors.full_messages,
    )
  end

  # .bulk_upsert!

  test ".bulk_upsert! upserts the given products" do
    enabled_one = self_service_affiliate_products(:enabled_ssap_for_product_1)
    enabled_two = self_service_affiliate_products(:enabled_ssap_for_product_2)
    product_three = links(:ssap_product_3)
    product_four = links(:ssap_product_4)

    products_with_details = [
      { id: enabled_one.product.external_id_numeric, enabled: false, name: enabled_one.product.name, fee_percent: 10, destination_url: nil },
      { id: enabled_two.product.external_id_numeric, enabled: false, fee_percent: 5, destination_url: "https://example.com" },
      { id: product_three.external_id_numeric, enabled: false, name: product_three.name, fee_percent: nil, destination_url: nil },
      { id: product_four.external_id_numeric, enabled: true, name: product_four.name, fee_percent: 25, destination_url: "https://example.com/test" },
    ]

    SelfServiceAffiliateProduct.bulk_upsert!(products_with_details, @creator.id)

    assert_equal false, enabled_one.reload.enabled
    assert_equal false, enabled_two.reload.enabled
    assert_equal "https://example.com", enabled_two.destination_url
    last = @creator.self_service_affiliate_products.last
    assert_equal(
      { "enabled" => true, "product_id" => product_four.id, "affiliate_basis_points" => 2500, "destination_url" => "https://example.com/test" },
      last.slice(:enabled, :product_id, :affiliate_basis_points, :destination_url),
    )
  end

  test ".bulk_upsert! raises an error with invalid params" do
    collab_product = links(:ssap_collab_product)
    products_with_details = [
      {
        id: collab_product.external_id_numeric,
        enabled: true,
        name: collab_product.name,
        fee_percent: 10,
        destination_url: nil,
      },
    ]

    error = assert_raises(ActiveRecord::RecordInvalid) do
      SelfServiceAffiliateProduct.bulk_upsert!(products_with_details, @creator.id)
    end
    assert_equal "Validation failed: Collab products cannot have affiliates", error.message
  end
end
