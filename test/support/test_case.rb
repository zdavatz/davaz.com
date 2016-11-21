module DaVaz
  module TestCase
    attr_reader :browser

    def before_setup
      SBSM.logger= ChronoLogger.new(DaVaz.config.log_pattern)
      @ci  = File.expand_path(File.join(__FILE__, '../../../etc/config.yml.ci'))
      @bak = File.expand_path(File.join(__FILE__, '../../../etc/config.yml.bak'))
      @cfg = File.expand_path(File.join(__FILE__, '../../../etc/config.yml'))
      FileUtils.cp(@cfg, @bak, verbose: true) if File.exist?(@cfg) && ! File.exist?(@bak)
      FileUtils.cp(@ci, @cfg, verbose: true)
      SBSM.info "@cfg #{@cfg} with #{File.read(@cfg)}"
      super
      startup_server
      boot_browser
    end

    def after_teardown
      close_browser
      shutdown_server
      FileUtils.cp(@bak, @cfg, verbose: true) if File.exist?(@cfg) && File.exist?(@bak)
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
