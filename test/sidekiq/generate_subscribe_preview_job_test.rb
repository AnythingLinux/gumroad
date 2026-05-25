# frozen_string_literal: true

require "test_helper"

class GenerateSubscribePreviewJobTest < ActiveSupport::TestCase
  # ActiveStorage attaches go through the configured service. Use the
  # leaf-pitfalls disk-service recipe so the .attach + blob.save! don't
  # try to reach MinIO/S3.
  self.use_transactional_tests = false

  setup do
    require "active_storage/service/disk_service"
    @storage_root = Rails.root.join("tmp/storage_test_#{SecureRandom.hex(4)}")
    @disk_service = ActiveStorage::Service::DiskService.new(root: @storage_root)
    @disk_service.name = :local_test
    services = ActiveStorage::Blob.services.instance_variable_get(:@services)
    @registered_prev = services[:local_test]
    services[:local_test] = @disk_service
    @original_service = ActiveStorage::Blob.service
    ActiveStorage::Blob.service = @disk_service

    @user = users(:basic_user)
  end

  teardown do
    ActiveStorage::Blob.service = @original_service if @original_service
    services = ActiveStorage::Blob.services.instance_variable_get(:@services)
    if @registered_prev
      services[:local_test] = @registered_prev
    else
      services.delete(:local_test)
    end
    FileUtils.rm_rf(@storage_root)
    ActiveStorage::Attachment.unscoped.delete_all
    ActiveStorage::Blob.unscoped.delete_all
  end

  test "#perform attaches the generated image to the user when generation works" do
    png_bytes = "\x89PNG\r\n\x1a\n".b + ("\x00" * 64)
    SubscribePreviewGeneratorService.define_singleton_method(:generate_pngs) { |_users| [png_bytes] }

    refute @user.subscribe_preview.attached?
    GenerateSubscribePreviewJob.new.perform(@user.id)
    assert @user.reload.subscribe_preview.attached?
  ensure
    SubscribePreviewGeneratorService.singleton_class.send(:remove_method, :generate_pngs)
  end

  test "#perform raises 'Subscribe Preview could not be generated' when image generation does not work" do
    SubscribePreviewGeneratorService.define_singleton_method(:generate_pngs) { |_users| [nil] }
    err = assert_raises(RuntimeError) { GenerateSubscribePreviewJob.new.perform(@user.id) }
    assert_equal "Subscribe Preview could not be generated for user.id=#{@user.id}", err.message
  ensure
    SubscribePreviewGeneratorService.singleton_class.send(:remove_method, :generate_pngs)
  end

  test "#perform propagates the error to Sidekiq" do
    SubscribePreviewGeneratorService.define_singleton_method(:generate_pngs) { |_users| raise "Failure" }
    assert_raises(RuntimeError, "Failure") { GenerateSubscribePreviewJob.new.perform(@user.id) }
  ensure
    SubscribePreviewGeneratorService.singleton_class.send(:remove_method, :generate_pngs)
  end
end
