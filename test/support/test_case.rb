require 'headless'
require 'util/app'
require 'util/drbserver'

module DaVaz
  module TestCase
    attr_reader :browser

    def before_setup
      super

      @headless ||= Headless.new
      @headless.start
      at_exit do
        @headless.destroy
      end

      unless @server
        @http_server ||= startup_server
        trap('INT') { @http_server.shutdown }
        @http_server.shutdown
        @server = Thread.new { @http_server.start }
      end

      @browser ||= open_browser
    end

    def setup
      # pass
    end

    def teardown
      # pass
    end

    def after_teardown
      shutdown_server if @server
      close_browser if @browser
      @headless.destroy
      super
    end

    private

    def startup_server
      drb_url = TEST_APP_URI.to_s
      app = DaVaz::Util::App.new
      app.db_manager = DaVaz::Stub::DbManager.new
      app.yus_server = DaVaz::Stub::YusServer.new

      server = DaVaz::Util::DRbServer.new(app)
      @drb ||= Thread.new do
        begin
          @drb_server ||= DRb.start_service(drb_url, server)
        rescue Exception => e
          puts e.class
          puts e.message
          puts e.backtrace
          raise
        end
      end
      @drb.abort_on_exception = true
      Stub.http_server(drb_url)
    end

    def shutdown_server
      @http_server.shutdown
      @drb_server.stop_service
      @drb = nil
    end

    def open_browser
      client = Selenium::WebDriver::Remote::Http::Default.new
      client.timeout = 900
      DaVaz::Browser.new(:firefox, http_client: client)
    end

    def close_browser
      @browser.close
      @browser = nil
    end

    #def login
    #	@selenium.click "link=Login"
    #	sleep 1
    #  @selenium.type "login_email", "right@user.ch"
    #  @selenium.type "login_password", "abcd"
    #	@selenium.click "document.loginform.login"
    #  @selenium.wait_for_page_to_load "30000"
    #end
  end
end
