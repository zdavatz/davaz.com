require 'util/app'

module DaVaz
  class Server
    def initialize
      at_exit { exit }
      @drb = Thread.new do
        begin
          SBSM.info "starting  DaVaz::Util::App on #{TEST_APP_URI.to_s}"
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
      SBSM.info "spawn test/config.ru #{File.exist?('test/config.ru')}"
      @pid = Process.spawn('bundle', 'exec', 'rackup', 'test/config.ru', { :err => ['test_rack.log', 'w+'],  :out => ['test_rack.log', 'w+']})
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
        @pid = nil
      end
    end
  end
end
