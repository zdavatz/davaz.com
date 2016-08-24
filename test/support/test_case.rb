module DaVaz
  module TestCase
    attr_reader :browser

    def before_setup
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
      return if @server
      at_exit { shutdown_server }

      @server = DaVaz::Server.new
    end

    def boot_browser
      return if @browser
      at_exit { close_browser }

      @browser = DaVaz::Browser.new
    end

    def close_browser
      return unless @browser

      begin
        @browser.close
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
