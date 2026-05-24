# frozen_string_literal: true

require "test_helper"

class RichContentsTest < ActiveSupport::TestCase
  # ---- product context ----

  test "rich_content_json returns product-level alive rich contents in order" do
    product = links(:rich_contents_product)
    rc1 = rich_contents(:rich_contents_product_page1)
    rc3 = rich_contents(:rich_contents_product_page3)

    assert_equal(
      [
        { id: rc3.external_id, page_id: rc3.external_id, variant_id: nil, title: "Page 3",
          description: { type: "doc", content: rc3.description }, updated_at: rc3.updated_at },
        { id: rc1.external_id, page_id: rc1.external_id, variant_id: nil, title: "Page 1",
          description: { type: "doc", content: rc1.description }, updated_at: rc1.updated_at },
      ],
      product.rich_content_json
    )
  end

  test "rich_content_json returns product-level rich contents when has_same_rich_content_for_all_variants is true" do
    product = links(:rich_contents_product)
    product.update!(has_same_rich_content_for_all_variants: true)

    rc1 = rich_contents(:rich_contents_product_page1)
    rc3 = rich_contents(:rich_contents_product_page3)

    assert_equal(
      [
        { id: rc3.external_id, page_id: rc3.external_id, variant_id: nil, title: "Page 3",
          description: { type: "doc", content: rc3.description }, updated_at: rc3.updated_at },
        { id: rc1.external_id, page_id: rc1.external_id, variant_id: nil, title: "Page 1",
          description: { type: "doc", content: rc1.description }, updated_at: rc1.updated_at },
      ],
      product.rich_content_json
    )
  end

  test "rich_content_json returns empty array when product has no rich content" do
    product = links(:rich_contents_other_product)
    # delete the lone other_product page so this product has nothing alive
    rich_contents(:rich_contents_other_product_page).update!(deleted_at: Time.current)
    assert_equal [], product.rich_content_json
  end

  test "rich_content_folder_name returns the folder name when the folder exists" do
    product = links(:rich_contents_folder_test_product)
    file1 = product_files(:rich_contents_folder_test_file1)
    file2 = product_files(:rich_contents_folder_test_file2)
    file3 = product_files(:rich_contents_folder_test_file3)
    file4 = product_files(:rich_contents_folder_test_file4)
    file5 = product_files(:rich_contents_folder_test_file5)

    folder1_id = SecureRandom.uuid
    folder2_id = SecureRandom.uuid

    product.rich_contents.create!(title: "Page 1", description: [], position: 0)

    assert_nil product.rich_content_folder_name(folder1_id)
    assert_nil product.rich_content_folder_name(folder2_id)

    page2_description = [
      { "type" => "fileEmbedGroup", "attrs" => { "name" => "folder 1", "uid" => folder1_id }, "content" => [
        { "type" => "fileEmbed", "attrs" => { "id" => file1.external_id, "uid" => SecureRandom.uuid } },
        { "type" => "fileEmbed", "attrs" => { "id" => file2.external_id, "uid" => SecureRandom.uuid } },
      ] },
      { "type" => "paragraph", "content" => [{ "type" => "text", "text" => "Ignore me" }] },
    ]

    page3_description = [
      {
        "type" => "fileEmbedGroup",
        "attrs" => { "name" => 100, "uid" => folder2_id },
        "content" => [
          { "type" => "fileEmbed", "attrs" => { "id" => file3.external_id, "uid" => SecureRandom.uuid } },
          { "type" => "fileEmbed", "attrs" => { "id" => file4.external_id, "uid" => SecureRandom.uuid } },
          { "type" => "fileEmbed", "attrs" => { "id" => file5.external_id, "uid" => SecureRandom.uuid } },
        ],
      },
    ]

    product.rich_contents.create!(title: "Page 2", description: page2_description, position: 1)
    product.rich_contents.create!(title: "Page 3", description: page3_description, position: 2)

    assert_equal "folder 1", product.reload.rich_content_folder_name(folder1_id)
    assert_equal "100", product.reload.rich_content_folder_name(folder2_id)
  end

  # ---- variant context ----

  test "variant rich_content_json returns variant-level alive rich contents" do
    variant = base_variants(:rich_contents_variant)
    rc1 = rich_contents(:rich_contents_variant_page1)
    rc3 = rich_contents(:rich_contents_variant_page3)

    assert_equal(
      [
        { id: rc3.external_id, page_id: rc3.external_id, variant_id: variant.external_id, title: "Page 3",
          description: { type: "doc", content: rc3.description }, updated_at: rc3.updated_at },
        { id: rc1.external_id, page_id: rc1.external_id, variant_id: variant.external_id, title: "Page 1",
          description: { type: "doc", content: rc1.description }, updated_at: rc1.updated_at },
      ],
      variant.rich_content_json
    )
  end

  test "variant rich_content_json returns empty when product has_same_rich_content_for_all_variants" do
    variant = base_variants(:rich_contents_variant)
    variant.variant_category.link.update!(has_same_rich_content_for_all_variants: true)
    assert_equal [], variant.rich_content_json
  end

  test "variant rich_content_json returns empty when variant has no rich content" do
    variant = base_variants(:rich_contents_other_variant)
    # delete the lone other_variant page so this variant has nothing alive
    rich_contents(:rich_contents_other_variant_page).update!(deleted_at: Time.current)
    assert_equal [], variant.rich_content_json
  end
end
