# frozen_string_literal: true

require "puma"
require "puma/server"
require "puma/log_writer"
require "rack"

# Boots the Rails app on an ephemeral port in a background thread so Playwright
# can hit it over real HTTP. One server per process; the URL is stable across
# tests so cookies/origins behave like a real browser session.
module SystemTests
  class Server
    HOST = "127.0.0.1"

    class << self
      def boot
        @boot ||= begin
          start
          at_exit { stop }
          true
        end
      end

      def base_url
        "http://#{HOST}:#{port}"
      end

      def port
        @port ||= find_free_port
      end

      private
        def start
          # Puma 6 dropped Puma::Events; use LogWriter.null to silence the
          # server's own output (Rails logs still flow to log/test.log).
          @server = Puma::Server.new(Rails.application, nil, log_writer: Puma::LogWriter.null)
          @server.add_tcp_listener(HOST, port)
          @thread = Thread.new { @server.run.join }
          wait_until_ready
        end

        def stop
          @server&.stop(true)
          @thread&.join(5)
        end

        def wait_until_ready
          deadline = Time.now + 10
          loop do
            TCPSocket.new(HOST, port).close
            return
          rescue Errno::ECONNREFUSED
            raise "Test server failed to start on #{HOST}:#{port}" if Time.now > deadline
            sleep 0.05
          end
        end

        def find_free_port
          server = TCPServer.new(HOST, 0)
          server.addr[1].tap { server.close }
        end
    end
  end
end
