require 'headless'
require 'util/davazapp'
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

      unless @browser
        drb_url = TEST_APP_URI.to_s
        app = DaVaz::Util::DaVazApp.new
        app.db_manager = DaVaz::Stub::DbManager.new
        app.yus_server = DaVaz::Stub::YusServer.new

        server = DaVaz::Util::DRbServer.new(app)
        drb ||= Thread.new do
          begin
            @drb_server ||= DRb.start_service(drb_url, server)
          rescue Exception => e
            puts e.class
            puts e.message
            puts e.backtrace
            raise
          end
        end
        drb.abort_on_exception = true

        @http_server ||= Stub.http_server(drb_url)
        trap('INT') { @http_server.shutdown }
        @http_server.shutdown

        @webrick ||= Thread.new { @http_server.start }
        @browser ||= DaVaz::Browser.new(:firefox)
      end
    end

    def teardown
      #@selenium.stop unless $selenium
      #@http_server.shutdown
      #@drb_server.stop_service
      #assert_equal [], @verification_errors
    end

    def after_teardown
      @http_server.shutdown
      @drb_server.stop_service
      @browser.close
      @headless.destroy
      super
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
