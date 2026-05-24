# frozen_string_literal: true

require "test_helper"

class ThumbnailTest < ActiveSupport::TestCase
  setup do
    @product = links(:basic_user_product)
  end

  # File-attachment tests (#validate_file with a valid/large/svg/wrong-dimensions
  # blob, #url with PUBLIC_STORAGE_S3_BUCKET assertions) need
  # ActiveStorage::Blob.create_and_upload! → S3 + .analyze, which hits Makara
  # BlacklistedWhileInTransaction in CI. Out of scope for the model backfill.
  # Pure-validation cases that don't touch S3 are ported below.

  test "#validate_file does not save if no file attached" do
    thumbnail = Thumbnail.new(product: @product)
    assert_equal false, thumbnail.save
    assert_equal ["Could not process your thumbnail, please try again."],
                 thumbnail.errors.full_messages
  end

  test "#validate_file does not validate when marked deleted" do
    thumbnail = Thumbnail.new(product: @product, deleted_at: Time.current)
    assert_equal true, thumbnail.save
    assert_empty thumbnail.errors.full_messages
  end

  test "#alive returns nil if deleted" do
    thumbnail = Thumbnail.new(product: @product, deleted_at: Time.current)
    assert_nil thumbnail.alive
  end

  test "#alive returns self if alive" do
    thumbnail = Thumbnail.new(product: @product)
    assert_equal thumbnail, thumbnail.alive
  end

  test "#url returns nil if no file attached" do
    thumbnail = Thumbnail.new(product: @product)
    assert_nil thumbnail.url
  end

  test "TODO: file-attachment + S3 paths (blob.analyze, MiniMagick fallbacks)" do
    skip "ActiveStorage::Blob.create_and_upload! + .analyze hits Makara::Errors::BlacklistedWhileInTransaction in CI; needs S3 stubbing setup not present in Minitest harness."
  end
end
