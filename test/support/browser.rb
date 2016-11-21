require 'selenium-webdriver'
require 'watir'

module DaVaz
  class Browser < SimpleDelegator

    def initialize
      case ENV['BROWSER']
      when /^firefox/i
        @browser = setup_firefox
      when /^phantomjs/i
        @browser = setup_phantomjs
      else
        @browser = setup_chromium
      end
      puts "For environment BROWSER (#{ ENV['BROWSER']}) we use #{@browser.driver.browser}" if $VERBOSE
      super @browser
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
      caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" =>
                                                              {"args" =>
                                                              [ "--disable-web-security" ,
                                                                '--headless',
                                                                '--no-sandbox',
                                                                '--no-default-browser-check',
                                                                '--no-first-run',
                                                                '--disable-default-apps',
                                                                ]})
      Watir::Browser.new :chrome, :prefs => prefs, desired_capabilities: caps
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
      puts "Setting up default profile for firefox"

      profile = Selenium::WebDriver::Firefox::Profile.new
      profile['browser.download.folderList'] = 2
      profile['browser.helperApps.alwaysAsk.force'] = false
      profile['browser.helperApps.neverAsk.saveToDisk'] = "application/zip;application/octet-stream;application/x-zip;application/x-zip-compressed;text/csv;test/semicolon-separated-values"

      bin_path = '/usr/bin/firefox-bin'
      Selenium::WebDriver::Firefox::Binary.path= bin_path if File.executable?(bin_path)
      caps = Selenium::WebDriver::Remote::Capabilities.firefox(marionette: true)
      @driver = Selenium::WebDriver.for :firefox
      Watir::Browser.new @driver, desired_capabilities: caps
    end
  end
end
