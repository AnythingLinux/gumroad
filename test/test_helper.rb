# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"
require "webmock/minitest"

# Disable network access in tests (matches RSpec's webmock config).
WebMock.disable_net_connect!(allow_localhost: true)

module ActiveSupport
  class TestCase
    # Reuse the existing fixture files we share with the RSpec suite for
    # things like `file_fixture(...)`.
    self.file_fixture_path = Rails.root.join("spec", "support", "fixtures")

    # Fixtures live under test/fixtures/. `fixtures :all` is only called
    # once there's at least one fixture file; tests that need fixtures
    # can call `fixtures :name` in their class body. We're on the
    # fixtures-only migration path (no FactoryBot).
    fixtures_dir = Rails.root.join("test", "fixtures")
    if fixtures_dir.directory? && Dir[fixtures_dir.join("*.yml")].any?
      fixtures :all
    end
  end
end

# Load shared test-support modules.
Dir[Rails.root.join("test", "support", "**", "*.rb")].sort.each { |f| require f }

# Stub Vite helpers so mailer/view tests don't depend on a built Vite manifest.
# CI builds no JS bundle (Minitest suite is Ruby-only), so we return empty tags.
# If a test needs the real Vite output, override these in the test class.
module ViteTestStubs
  def vite_javascript_tag(*_args, **_kwargs); "".html_safe; end
  def vite_typescript_tag(*_args, **_kwargs); "".html_safe; end
  def vite_stylesheet_tag(*_args, **_kwargs); "".html_safe; end
  def vite_entrypoint_stylesheet_tag(*_args, **_kwargs); "".html_safe; end
  def vite_client_tag(*_args, **_kwargs); "".html_safe; end
  def vite_react_refresh_tag(*_args, **_kwargs); "".html_safe; end
  def vite_asset_path(name, *_args, **_kwargs); "/vite-test/#{name}"; end
  def vite_asset_url(name, *_args, **_kwargs); "/vite-test/#{name}"; end
  def vite_image_tag(name, *_args, **_kwargs); image_tag("/vite-test/#{name}"); end
end

ActionMailer::Base.helper(ViteTestStubs)
ActionView::Base.send(:include, ViteTestStubs) if defined?(ActionView::Base)
