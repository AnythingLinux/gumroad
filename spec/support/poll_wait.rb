# frozen_string_literal: true

# Drop-in replacement for Selenium::WebDriver::Wait used as a generic
# polling helper in specs. Polls a block until it returns truthy, with
# a configurable timeout (default 30s) and interval (default 0.5s).
#
# Usage:
#   wait = PollWait.new(timeout: 10)
#   wait.until { SomeModel.exists? }
#
class PollWait
  class TimeoutError < StandardError; end

  def initialize(timeout: 30, interval: 0.5)
    @timeout = timeout
    @interval = interval
  end

  def until
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + @timeout
    loop do
      result = yield
      return result if result

      remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
      raise TimeoutError, "Timed out after #{@timeout}s waiting for condition" if remaining <= 0

      sleep [@interval, remaining].min
    end
  end
end
