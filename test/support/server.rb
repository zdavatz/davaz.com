require 'test_helper'
require 'util/app'
require 'net/http'

module DaVaz
  class TestServer
    def initialize
      at_exit { exit }
      log_file = 'rack_test.log'
      SBSM.info "spawn test/config.ru #{File.exist?('test/config.ru')}"
      @pid = Process.spawn('bundle', 'exec', 'rackup', '-p', '11090', 'test/config.ru', { :err => [log_file, 'w+'],  :out => [log_file, 'w+']})
      SBSM.info msg =  "Started #{DaVaz.config.server_uri} PID #{@pid}"
      wait_until_ready
      @pid
    end

    def exit
      DRb.stop_service
      if @pid
        puts "stop_davaz_and_browser ensure killing @pid: #{@pid}" # if $VERBOSE
        Process.kill("QUIT", @pid)
        Process.wait(@pid)
        @pid = nil
      end
    end

    private

    def wait_until_ready(timeout = 30)
      uri = URI.parse("http://localhost:11090/")
      start = Time.now
      loop do
        begin
          response = Net::HTTP.get_response(uri)
          return if response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
        rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL, SocketError
          # server not ready yet
        end
        if Time.now - start > timeout
          raise "Test server failed to start within #{timeout} seconds"
        end
        sleep 0.5
      end
    end
  end
end
