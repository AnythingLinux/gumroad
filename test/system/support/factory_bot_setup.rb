# frozen_string_literal: true

# Reuse the existing factories from the RSpec suite so we don't fork the
# factory definitions during the migration.
FactoryBot.definition_file_paths = [Rails.root.join("spec", "support", "factories").to_s]
FactoryBot.find_definitions

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods
  end
end
