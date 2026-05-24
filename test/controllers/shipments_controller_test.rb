# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. The verify_shipping_address path calls EasyPost's
# API under VCR cassettes that don't exist in the Minitest harness. The
# mark_as_shipped paths require fixture purchases tied to a physical product
# (require_shipping column + native_type physical) with admin-for-seller
# membership — net-new fixture surface.
# Original: spec/controllers/shipments_controller_spec.rb.
class ShipmentsControllerTest < ActiveSupport::TestCase
  test "TODO: migrate spec/controllers/shipments_controller_spec.rb" do
    skip "TODO: EasyPost VCR cassettes + physical purchase fixture surface"
  end
end
