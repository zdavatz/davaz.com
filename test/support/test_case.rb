require 'headless'
require 'util/app'
require 'util/drbserver'

module DaVaz
  module TestCase
    attr_reader :browser

    def before_setup
      super

      if TEST_HEADLESS && !@headless
        @headless = Headless.new
        @headless.start
        at_exit { @headless.destroy if @headless }
      end

      startup_server
      boot_browser
    end

    def setup
      # pass
    end

    def teardown
      # pass
    end

    def after_teardown
      close_browser
      shutdown_server

      if TEST_HEADLESS && @headless
        @headless.destroy
        @headless = nil
      end

      super
    end

    private

    def startup_server
      return if @server

      drb_url = TEST_APP_URI.to_s
      app = DaVaz::Util::App.new
      app.db_manager = DaVaz::Stub::DbManager.new
      app.yus_server = DaVaz::Stub::YusServer.new

      server = DaVaz::Util::DRbServer.new(app)
      @drb = Thread.new do
        begin
          @drb_server = DRb.start_service(drb_url, server)
        rescue Exception => e
          $stdout.puts e.class
          $stdout.puts e.message
          $stdout.puts e.backtrace
          raise
        end
      end
      #@drb.abort_on_exception = true
      @http_server = Stub.http_server(drb_url)
      @http_server.shutdown
      trap('INT') { @http_server.shutdown }

      @server = Thread.new { @http_server.start }
    end

    def shutdown_server
      return unless @server

      @http_server.shutdown
      @http_server = nil
      @drb_server.stop_service
      @drb_server = nil
      @drb.exit
      @drb = nil
      @server.exit
      @server = nil
    end

    def boot_browser
      return if @browser

      client = Selenium::WebDriver::Remote::Http::Default.new
      client.timeout = TEST_CLIENT_TIMEOUT
      @browser = DaVaz::Browser.new(:firefox, http_client: client)
    end

    def close_browser
      return unless @browser

      @browser.close
      @browser = nil
    end
  end
end
