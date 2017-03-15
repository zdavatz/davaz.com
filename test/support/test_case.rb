require 'test_helper'
require 'support/server'

module DaVaz
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
    add_filter "/gems/"
  end

  module TestCase
    attr_reader :browser

    def before_setup
      SBSM.logger= ChronoLogger.new(DaVaz.config.log_pattern)
      super
      startup_server
      boot_browser
    end

    def after_teardown
      close_browser
      shutdown_server
      super
    end

    private

    def startup_server
      puts "startup_server @server is #{@server.class}"
      return if @server
      at_exit { shutdown_server }

      @server = DaVaz::TestServer.new
    end

    def boot_browser
      return if @browser
      at_exit { close_browser }

      @browser = DaVaz::Browser.new
    end

    def close_browser
      return unless @browser

      begin
        @browser.quit
      rescue Errno::ECONNREFUSED
      end
      @browser = nil
    end

    def shutdown_server
      return unless @server

      begin
        @server.exit
      rescue Exception => e
        $stdout.puts e.class
      end
      @server = nil
    end
  end
end
