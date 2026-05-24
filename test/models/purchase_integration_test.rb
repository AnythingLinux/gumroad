# frozen_string_literal: true

require "test_helper"

class PurchaseIntegrationTest < ActiveSupport::TestCase
  setup do
    @purchase = purchases(:auto_invoice_enabled_purchase)
    @product = @purchase.link
    @integration = integrations(:circle_integration_one)
    @discord_integration = integrations(:discord_integration_for_not_enabled_product)
    # Ensure clean slate for this purchase + a single known circle integration on the product.
    PurchaseIntegration.where(purchase_id: @purchase.id).delete_all
    ProductIntegration.where(product_id: @product.id).delete_all
    ProductIntegration.create!(product: @product, integration: @integration)
  end

  test "raises error if purchase_id is not present" do
    pi = PurchaseIntegration.new(purchase_id: nil, integration_id: @integration.id)
    assert_not pi.valid?
    assert_includes pi.errors.full_messages, "Purchase can't be blank"
  end

  test "raises error if integration_id is not present" do
    pi = PurchaseIntegration.new(purchase_id: @purchase.id, integration_id: nil)
    assert_not pi.valid?
    assert_includes pi.errors.full_messages, "Integration can't be blank"
  end

  test "raises error if (purchase_id, integration_id) is not unique" do
    # named_seller_product has circle_integration_one wired in fixtures
    PurchaseIntegration.create!(purchase: @purchase, integration: @integration)
    pi2 = PurchaseIntegration.new(purchase: @purchase, integration: @integration)
    assert_not pi2.valid?
    assert_includes pi2.errors.full_messages, "Integration has already been taken"
  end

  test "is successful if (purchase_id, integration_id) is not unique but all clashing entries have been deleted" do
    # discord case — need discord integration on the product
    discord_product_integration = ProductIntegration.create!(product: @product, integration: @discord_integration)
    pi1 = PurchaseIntegration.create!(purchase: @purchase, integration: @discord_integration, discord_user_id: "user-0", deleted_at: 1.day.ago)
    pi2 = PurchaseIntegration.create!(purchase: @purchase, integration: @discord_integration, discord_user_id: "user-1")
    assert pi2.valid?
    assert pi2.persisted?
  ensure
    discord_product_integration&.destroy
  end

  test "raises error if same purchase has different integrations of same type" do
    # Create a PI for circle_integration_one (which IS on the product).
    PurchaseIntegration.create!(purchase: @purchase, integration: @integration)
    # Try to validate a PI for a DIFFERENT circle integration not on the product:
    # both `unique_for_integration_type` AND `matches_integration_on_product` will fire;
    # the spec only asserts the "multiple integrations of same type" message is present.
    pi2 = PurchaseIntegration.new(purchase: @purchase, integration: integrations(:circle_integration_two))
    assert_not pi2.valid?
    assert_includes pi2.errors.full_messages, "Purchase cannot have multiple integrations of the same type."
  end

  test "is successful if same purchase has integrations of different type" do
    # Wire discord on product as well
    ProductIntegration.create!(product: @product, integration: @discord_integration)
    PurchaseIntegration.create!(purchase: @purchase, integration: @integration)
    pi2 = PurchaseIntegration.create!(purchase: @purchase, integration: @discord_integration, discord_user_id: "user-1")
    assert pi2.valid?
    assert pi2.persisted?
  end

  test "raises error if discord_user_id is not present for a discord integration" do
    ProductIntegration.create!(product: @product, integration: @discord_integration)
    pi = PurchaseIntegration.new(purchase: @purchase, integration: @discord_integration)
    assert_not pi.valid?
    assert_includes pi.errors.full_messages, "Discord user can't be blank"
  end

  test "raises error if purchase and the associated standalone product have different integrations" do
    # @product is wired to circle only — try a discord PI without wiring discord on the product
    pi = PurchaseIntegration.new(purchase: @purchase, integration: @discord_integration, discord_user_id: "user-0")
    assert_not pi.valid?
    assert_includes pi.errors.full_messages, "Integration does not match the one available for the associated product."
  end

  test "raises error if purchase and the associated variant have different integrations" do
    variant = base_variants(:integrations_test_variant_v1)
    # Variant is wired to circle_integration_for_variant_one/two via base_variant_integrations fixtures.
    # Attach the variant to our purchase so find_enabled_integration consults the variant.
    # Use a low-level insert to bypass full Purchase validation.
    BaseVariantsPurchase.create!(purchase_id: @purchase.id, base_variant_id: variant.id)
    @purchase.reload
    # @integration is circle_integration_one, NOT one of the variant's integrations.
    pi = PurchaseIntegration.new(purchase: @purchase, integration: @integration)
    assert_not pi.valid?
    assert_includes pi.errors.full_messages, "Integration does not match the one available for the associated product."
  end
end
