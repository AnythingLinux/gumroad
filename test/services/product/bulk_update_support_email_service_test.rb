# frozen_string_literal: true

require "test_helper"

class Product::BulkUpdateSupportEmailServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:named_seller)
    @product1 = links(:ssap_product_1)
    @product2 = links(:ssap_product_2)
    @product3 = links(:ssap_product_3)
    [@product1, @product2, @product3].each { |p| p.update_columns(support_email: "old#{p.id % 1000}@example.com") }
    @initial = { @product1.id => @product1.support_email, @product2.id => @product2.support_email, @product3.id => @product3.support_email }

    @other_user_product = links(:another_seller_product)
    @other_user_product.update_columns(support_email: "other@example.com")

    Feature.activate_user(:product_level_support_emails, @user)
  end

  teardown do
    Feature.deactivate_user(:product_level_support_emails, @user) if @user
  end

  test "updates products support emails according to entries" do
    entries = [
      { email: "new1+2@example.com", product_ids: [@product1.external_id, @product2.external_id] },
      { email: "new3@example.com", product_ids: [@product3.external_id] },
    ]

    Product::BulkUpdateSupportEmailService.new(@user, entries).perform

    assert_equal "new1+2@example.com", @product1.reload.support_email
    assert_equal "new1+2@example.com", @product2.reload.support_email
    assert_equal "new3@example.com",  @product3.reload.support_email
  end

  test "raises an error if any of the emails is invalid" do
    entries = [
      { email: "new1@example.com", product_ids: [@product1.external_id] },
      { email: "invalid",          product_ids: [@product2.external_id] },
    ]

    err = assert_raises(ActiveModel::ValidationError) do
      Product::BulkUpdateSupportEmailService.new(@user, entries).perform
    end
    assert_match(/Support email is invalid/, err.message)

    assert_equal @initial[@product1.id], @product1.reload.support_email
    assert_equal @initial[@product2.id], @product2.reload.support_email
    assert_equal @initial[@product3.id], @product3.reload.support_email
  end

  test "clears support emails for products not in any entry" do
    entries = [{ email: "new1@example.com", product_ids: [@product1.external_id] }]

    Product::BulkUpdateSupportEmailService.new(@user, entries).perform

    assert_equal "new1@example.com", @product1.reload.support_email
    assert_nil @product2.reload.support_email
    assert_nil @product3.reload.support_email
  end

  test "clears all support emails when provided empty array" do
    Product::BulkUpdateSupportEmailService.new(@user, []).perform

    assert_nil @product1.reload.support_email
    assert_nil @product2.reload.support_email
    assert_nil @product3.reload.support_email
  end

  test "clears all support emails when provided nil" do
    Product::BulkUpdateSupportEmailService.new(@user, nil).perform

    assert_nil @product1.reload.support_email
    assert_nil @product2.reload.support_email
    assert_nil @product3.reload.support_email
  end

  test "does not update products that do not belong to the user" do
    entries = [
      { email: "new1@example.com", product_ids: [@product1.external_id] },
      { email: "new2@example.com", product_ids: [@other_user_product.external_id] },
    ]

    Product::BulkUpdateSupportEmailService.new(@user, entries).perform

    assert_equal "new1@example.com", @product1.reload.support_email
    assert_equal "other@example.com", @other_user_product.reload.support_email
  end

  test "when user does not have product_level_support_emails enabled, does not update any product support emails" do
    Feature.deactivate_user(:product_level_support_emails, @user)

    entries = [{ email: "new@example.com", product_ids: [@product1.external_id] }]
    Product::BulkUpdateSupportEmailService.new(@user, entries).perform

    assert_equal @initial[@product1.id], @product1.reload.support_email
    assert_equal @initial[@product2.id], @product2.reload.support_email
    assert_equal @initial[@product3.id], @product3.reload.support_email
  end
end
