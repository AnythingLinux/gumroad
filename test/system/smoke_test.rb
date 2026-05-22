# frozen_string_literal: true

require_relative "test_helper"

# Proves the full stack boots: Puma serving the app, Playwright launched, a new
# context navigating to a real URL and reading HTML back. Add real coverage in
# sibling files; this one stays minimal.
class SmokeTest < SystemTests::SystemTestCase
  def test_root_page_returns_html
    response = page.goto(url_for("/"))
    assert response, "page.goto returned nil"
    assert response.ok?, "expected 2xx from / but got #{response.status}"
    assert_match(/<html/i, page.content)
  end
end
