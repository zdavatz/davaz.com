require 'test_helper'
require 'util/app'

module DaVaz
  class TestServer
    def initialize
      at_exit { exit }
      log_file = 'rack_test.log'
      SBSM.info "spawn test/config.ru #{File.exist?('test/config.ru')}"
      @pid = Process.spawn('bundle', 'exec', 'rackup', 'test/config.ru', { :err => [log_file, 'w+'],  :out => [log_file, 'w+']})
      SBSM.info msg =  "Started #{DaVaz.config.server_uri} PID #{@pid}"
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
  end
end
