# frozen_string_literal: true

require_relative "../test_helper"
require "playwright"
require "rack/handler/puma"
require "database_cleaner/active_record"
require "factory_bot"

require_relative "support/server"
require_relative "support/playwright_driver"
require_relative "support/factory_bot_setup"
require_relative "system_test_case"
