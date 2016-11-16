require 'util/app'
require 'util/drbserver'

module DaVaz
  class Server
    def initialize
      drb_url = TEST_APP_URI.to_s
      app = DaVaz::Util::App.new
      app.db_manager = DaVaz::Stub::DbManager.new
      app.yus_server = DaVaz::Stub::YusServer.new

      at_exit { exit }
      @drb = Thread.new do
        begin
          DRb.stop_service
          DRb.start_service(TEST_APP_URI.to_s, DaVaz::Util::App.new)
          DRb.thread.join
        rescue Exception => e
          $stdout.puts e.class
          $stdout.puts e.message
          $stdout.puts e.backtrace
          raise
        end
      end
      @pid = Process.spawn('bundle', 'exec', 'rackup', 'test/config.ru', { :err => ['test_error.log', 'w+']})
      SBSM.info msg =  "Starting #{DaVaz.config.server_uri} PID #{@pid}"
      @drb.abort_on_exception = true
      trap('INT') { @drb.exit }
    end

    def exit
      puts "stop_davaz_and_browser ensure killing @pid: #{@pid}" if $VERBOSE
      DRb.stop_service
      if @pid
        Process.kill("QUIT", @pid)
        Process.wait(@pid)
      end
    end
  end
end
