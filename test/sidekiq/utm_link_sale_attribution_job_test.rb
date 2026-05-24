# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/utm_link_sale_attribution_job_spec.rb (38 FactoryBot refs, 172 lines).
#
# Blocker for batch B backfill: Builds `:utm_link` + `:order` + `:utm_link_visit` + `:utm_link_driven_sale` + `:purchase` and asserts on `UtmLinkDrivenSale` insertion under 4 branches (visit-window, conversion-window, buyer browser_guid, IP-fallback). No fixtures for `:utm_link` / `:utm_link_visit` / `:utm_link_driven_sale` and the time-window assertions need `travel_to` plus exact buyer browser_guid matching. Out of scope.
class UtmLinkSaleAttributionJobTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/utm_link_sale_attribution_job_spec.rb — Builds `:utm_link` + `:order` + `:utm_link_visit` + `:utm_link_driven_sale` + `:purchase` and asserts on `UtmLinkDrivenSale` insertion under 4 branches (visit-window, conversion-window, buyer browser_guid, IP-fallback). No fixtures for `:utm_link` / `:utm_link_visit` / `:utm_link_driven_sale` and the time-window assertions need `travel_to` plus..."
  end
end
