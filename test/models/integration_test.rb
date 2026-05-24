# frozen_string_literal: true

require "test_helper"

class IntegrationTest < ActiveSupport::TestCase
  test "#type_for returns the type for the given integration name" do
    {
      Integration::CIRCLE => CircleIntegration.name,
      Integration::DISCORD => DiscordIntegration.name,
      Integration::ZOOM => ZoomIntegration.name,
      Integration::GOOGLE_CALENDAR => GoogleCalendarIntegration.name
    }.each do |name, expected_type|
      assert_equal expected_type, Integration.type_for(name)
    end
  end

  test "#class_for returns the class for the given integration name" do
    {
      Integration::CIRCLE => CircleIntegration,
      Integration::DISCORD => DiscordIntegration,
      Integration::ZOOM => ZoomIntegration,
      Integration::GOOGLE_CALENDAR => GoogleCalendarIntegration
    }.each do |name, expected_class|
      assert_equal expected_class, Integration.class_for(name)
    end
  end

  test "#name returns the name for each integration type" do
    {
      Integration::CIRCLE => integrations(:circle_integration_one),
      Integration::DISCORD => integrations(:discord_integration_for_not_enabled_product),
      Integration::ZOOM => integrations(:zoom_integration_basic),
      Integration::GOOGLE_CALENDAR => integrations(:google_calendar_integration_one)
    }.each do |expected_name, integration|
      assert_equal expected_name, integration.name
    end
  end

  test ".enabled_integrations_for returns the enabled integrations on a purchase" do
    purchase = purchases(:auto_invoice_enabled_purchase)
    product = purchase.link
    ProductIntegration.where(product_id: product.id).delete_all
    ProductIntegration.create!(product: product, integration: integrations(:circle_integration_one))

    assert_equal({ "circle" => true, "discord" => false, "zoom" => false, "google_calendar" => false },
                 Integration.enabled_integrations_for(purchase))
  end

  test ".enabled_integrations_for does not consider deleted integrations as enabled" do
    purchase = purchases(:auto_invoice_no_billing_purchase)
    product = purchase.link
    ProductIntegration.where(product_id: product.id).delete_all
    circle_pi = ProductIntegration.create!(product: product, integration: integrations(:circle_integration_one))
    ProductIntegration.create!(product: product, integration: integrations(:discord_integration_for_not_enabled_product))
    circle_pi.mark_deleted!

    assert_equal({ "circle" => false, "discord" => true, "zoom" => false, "google_calendar" => false },
                 Integration.enabled_integrations_for(purchase))
  end

  test "by_name scope returns collection of integrations of the given integration type" do
    circle_ids = [
      integrations(:circle_integration_one).id,
      integrations(:circle_integration_two).id,
      integrations(:circle_integration_for_variant_one).id,
      integrations(:circle_integration_for_variant_two).id
    ].sort
    assert_equal circle_ids, Integration.by_name(Integration::CIRCLE).order(:id).pluck(:id).sort
  end

  test "has one product_integration association" do
    integration = integrations(:circle_integration_one)
    pi = integration.product_integration
    assert_not_nil pi
    assert_equal ActiveRecord::FixtureSet.identify(:named_seller_product), pi.product_id
  end
end
