require 'util/app'
require 'util/drbserver'

module DaVaz
  class Server
    def initialize
      drb_url = TEST_APP_URI.to_s
      app = DaVaz::Util::App.new
      app.db_manager = DaVaz::Stub::DbManager.new
      app.yus_server = DaVaz::Stub::YusServer.new

      server = DaVaz::Util::DRbServer.new(app)
      @drb = Thread.new do
        begin
          DRb.stop_service
          @drb_server = DRb.start_service(drb_url, server)
          DRb.thread.join
        rescue Exception => e
          $stdout.puts e.class
          $stdout.puts e.message
          $stdout.puts e.backtrace
          raise
        end
      end
      @drb.abort_on_exception = true
      trap('INT') { @drb.exit }

      @http_server = Stub.http_server(drb_url)
      @http_server.shutdown
      trap('INT') { @http_server.shutdown }

      @server = Thread.new { @http_server.start }
      trap('INT') { @server.exit }

      @server
    end

    def exit
      @http_server.shutdown
      @http_server = nil

      @drb_server.stop_service
      @drb_server = nil
      @drb.exit
      @drb = nil

      @server.exit
      Thread.kill(@server)
      @server = nil
    end
  end
end
