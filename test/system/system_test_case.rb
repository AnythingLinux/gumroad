# frozen_string_literal: true

# Base class for browser tests driven by Playwright.
#
#   class SignupTest < SystemTests::SystemTestCase
#     def test_sign_up_succeeds
#       page.goto(url_for("/signup"))
#       page.fill('input[name="user[email]"]', "buyer@example.com")
#       page.click("button[type=submit]")
#       assert_match(/welcome/i, page.content)
#     end
#   end
#
# Each test gets a fresh Playwright context (clean cookies/storage) and page.
# DB state is reset via DatabaseCleaner truncation because the Puma server
# runs on a separate thread and can't share a transaction with the test.
module SystemTests
  class SystemTestCase < ActiveSupport::TestCase
    self.use_transactional_tests = false

    attr_reader :page, :context

    class << self
      def boot_dependencies!
        return if @booted
        Server.boot
        PlaywrightDriver.boot
        DatabaseCleaner.strategy = :truncation, { except: %w[ar_internal_metadata schema_migrations] }
        @booted = true
      end
    end

    def setup
      super
      self.class.boot_dependencies!
      DatabaseCleaner.start
      @context = PlaywrightDriver.new_context
      @context.set_default_timeout(PlaywrightDriver::DEFAULT_TIMEOUT_MS)
      @page = @context.new_page
    end

    def teardown
      super
      @page&.close
      @context&.close
      DatabaseCleaner.clean
    end

    def url_for(path)
      raise ArgumentError, "path must start with /" unless path.start_with?("/")
      "#{Server.base_url}#{path}"
    end
  end
end
