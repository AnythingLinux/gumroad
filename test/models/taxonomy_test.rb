require "test_helper"

class TaxonomyTest < ActiveSupport::TestCase
  # --- slug presence ---

  test "valid when slug is present" do
    assert Taxonomy.new(slug: "example").valid?
  end

  test "invalid when slug is not present" do
    taxonomy = Taxonomy.new(slug: nil)
    assert_not taxonomy.valid?
    assert_includes taxonomy.errors.full_messages, "Slug can't be blank"
  end

  # --- slug uniqueness, parent_id nil ---

  test "valid when parent is nil and no sibling taxonomy with same slug" do
    assert Taxonomy.new(slug: "fresh-slug-no-parent").valid?
  end

  test "invalid when parent is nil and a sibling taxonomy with same slug exists" do
    Taxonomy.create!(slug: "example")
    taxonomy = Taxonomy.new(slug: "example")
    assert_not taxonomy.valid?
    assert_includes taxonomy.errors.full_messages, "Slug has already been taken"
  end

  # --- slug uniqueness with parent ---

  test "valid when parent is set and no sibling with same slug under that parent" do
    parent = taxonomies(:design)
    assert Taxonomy.new(slug: "fresh-slug-under-parent", parent: parent).valid?
  end

  test "invalid when parent is set and a sibling with same slug already exists under that parent" do
    parent = taxonomies(:design)
    Taxonomy.create!(slug: "example", parent: parent)
    taxonomy = Taxonomy.new(slug: "example", parent: parent)
    assert_not taxonomy.valid?
    assert_includes taxonomy.errors.full_messages, "Slug has already been taken"
  end
end
