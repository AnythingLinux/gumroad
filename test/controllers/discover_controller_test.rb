# frozen_string_literal: true

require "test_helper"

# Partial migration: DiscoverController#index touches the SearchProducts concern,
# which routes through Link.search → Elasticsearch aggregations. The global
# EsClient stub returns `{}` for aggregations, so the controller crashes at
# `product_response.aggregations["tags.keyword"]["buckets"]` before reaching the
# inertia render path. Asserting on success path requires a real ES cluster or
# a much heavier stub layer than skip-stub budget allows.
class DiscoverControllerTest < ActionController::TestCase
  test "TODO: migrate spec/controllers/discover_controller_spec.rb" do
    skip "TODO: SearchProducts concern + Link.search ES aggregations — see comment above"
  end
end
