# frozen_string_literal: true

require "test_helper"

# Partial migration: DashboardController#index drives CreatorAnalytics through
# `CreatorAnalytics::ProductPageViews#paginate` which iterates over ES response
# `aggregations["per_product"]["buckets"]`. The global EsClient stub returns no
# aggregations, so the dashboard load crashes before reaching the inertia render
# path. Asserting on success needs a live ES cluster or a heavy stub layer that
# replaces both Sales aggregations and product-page-view aggregations.
class DashboardControllerTest < ActionController::TestCase
  test "TODO: migrate spec/controllers/dashboard_controller_spec.rb" do
    skip "TODO: CreatorAnalytics::ProductPageViews ES buckets — see comment above"
  end
end
