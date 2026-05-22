# frozen_string_literal: true

# Single Playwright process + single browser per test process. Each test gets
# its own context (fresh cookies, storage) and page. Keep this as the only
# place that touches Playwright; tests use the helpers on SystemTestCase.
module SystemTests
  class PlaywrightDriver
    HEADLESS = ENV.fetch("HEADED", "false") != "true"
    SLOW_MO_MS = ENV.fetch("SLOWMO", "0").to_i
    VIEWPORT = { width: 1280, height: 800 }.freeze
    DEFAULT_TIMEOUT_MS = 10_000

    class << self
      def browser
        boot
        @browser
      end

      def new_context(**options)
        browser.new_context(viewport: VIEWPORT, **options)
      end

      def boot
        @boot ||= begin
          @playwright = Playwright.create(playwright_cli_executable_path: cli_path).playwright
          @browser = @playwright.chromium.launch(headless: HEADLESS, slowMo: SLOW_MO_MS)
          at_exit { teardown }
          true
        end
      end

      private
        def teardown
          @browser&.close
          @playwright&.stop
        end

        def cli_path
          # `npx playwright` resolves the version pinned in package.json; if the
          # repo gets its own playwright npm dep later we can pin it explicitly.
          ENV.fetch("PLAYWRIGHT_CLI", "npx playwright")
        end
    end
  end
end
