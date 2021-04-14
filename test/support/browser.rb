require 'watir'

module DaVaz
  class Browser < SimpleDelegator
    attr_reader :id
    def initialize(which_one = ENV['BROWSER'], id: 1)
      which_one ||= 'firefox' if /debian|ubuntu/i.match(`lsb_release --id`.chomp.split("\t")[-1])
      @id = id
      case which_one
      when /^firefox/i
        browser = setup_firefox
      when /^phantomjs/i
        browser = setup_phantomjs
      else
        browser = setup_chromium
      end
      puts "For environment BROWSER (#{ENV['BROWSER']}) we use #{browser.driver.browser} id #{id}" # if $VERBOSE
      @browser = browser
      at_exit { @browser.close }
      super browser
    end

    def visit(path)
      @browser.goto(TEST_SRV_URI.to_s + path)
    end
  private
    # returns a Watir-Browser for Chromium
    # with same changes to the default profile
    def setup_chromium
      prefs = {
        :download => {:prompt_for_download => false, }
      }
      bin_path = nil
      [ `which google-chrome-stable`.chomp,
        `which google-chrome-beta`.chomp,
        `which google-chrome`.chomp,
      ].each do |path|
        if File.exist?(path)
          bin_path = path
          break
        end
      end
      exit(3) unless bin_path
      puts "Using #{bin_path} for watir tests"

      caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" =>
                                                              {"args" =>
                                                              [ "--disable-web-security" ,
                                                                '--headless',
                                                                '--no-sandbox',
                                                                '--no-default-browser-check',
                                                                '--no-first-run',
                                                                '--disable-default-apps',
                                                                ]},
                                                              "binary" => bin_path
                                                             )
      caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {"args" => [ "--disable-web-security" ]})
      @driver = Selenium::WebDriver.for :chrome
      puts "Starting chromium with #{bin_path} exist? #{File.exist?(bin_path)}"
      browser = Watir::Browser.new @driver, :prefs => prefs, desired_capabilities: caps
      browser
    end
    # returns a Watir-Browser for PhantomJS
    # with same changes to the default profile
    def setup_phantomjs
      client = Selenium::WebDriver::Remote::Http::Default.new
      client.timeout = TEST_CLIENT_TIMEOUT
      path = File.expand_path(
        '../../../node_modules/phantomjs-prebuilt/bin/phantomjs', __FILE__)
      Selenium::WebDriver::PhantomJS.path = path
      phantomjs_args = [
        '--debug=true',
        '--web-security=false',
        '--load-images=false',
        '--ignore-ssl-errors=true'
      ]
      Watir::Browser.new(:phantomjs, args: phantomjs_args, http_client: client)
    end
    # returns a Watir-Browser for firefox
    # with same changes to the default profile (e.g. folderlist, save to disk automatically)
    def setup_firefox
      puts "Setting up default profile for firefox" if $VERBOSE
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile['browser.download.folderList'] = 2
      profile['browser.helperApps.alwaysAsk.force'] = false
      profile['browser.helperApps.neverAsk.saveToDisk'] = "application/zip;application/octet-stream;application/x-zip;application/x-zip-compressed;text/csv;test/semicolon-separated-values"
      profile["network.http.prompt-temp-redirect"] = false
      bin_path = nil
      ['/usr/local/bin/firefox-bin',
       '/usr/bin/firefox-bin',
       '/usr/bin/firefox'].each do |path|
        if File.exist?(path)
          bin_path = path
          break
        end
      end
      Selenium::WebDriver::Firefox::Binary.path= bin_path if File.executable?(bin_path)
      caps = Selenium::WebDriver::Remote::Capabilities.firefox(marionette: true)
      @driver = Selenium::WebDriver.for :firefox
      browser = Watir::Browser.new @driver, profile: profile, desired_capabilities: caps
      browser
    end
  end
end
