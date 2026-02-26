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
    def setup_chromium
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

      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless')
      options.add_argument('--no-sandbox')
      options.add_argument('--disable-web-security')
      options.add_argument('--no-default-browser-check')
      options.add_argument('--no-first-run')
      options.add_argument('--disable-default-apps')
      options.add_argument('--disable-gpu')
      options.binary = bin_path

      browser = Watir::Browser.new(:chrome, options: options)
      browser
    end

    def setup_phantomjs
      raise "PhantomJS is no longer supported. Use chrome or firefox instead."
    end

    def setup_firefox
      puts "Setting up default profile for firefox" if $VERBOSE
      options = Selenium::WebDriver::Firefox::Options.new
      options.add_argument('--headless')

      bin_path = nil
      ['/usr/local/bin/firefox-bin',
       '/usr/bin/firefox-bin',
       '/usr/bin/firefox'].each do |path|
        if File.exist?(path)
          bin_path = path
          break
        end
      end
      options.binary = bin_path if bin_path && File.executable?(bin_path)

      profile = Selenium::WebDriver::Firefox::Profile.new
      profile['browser.download.folderList'] = 2
      profile['browser.helperApps.alwaysAsk.force'] = false
      profile['browser.helperApps.neverAsk.saveToDisk'] = "application/zip;application/octet-stream;application/x-zip;application/x-zip-compressed;text/csv;test/semicolon-separated-values"
      profile["network.http.prompt-temp-redirect"] = false
      options.profile = profile

      browser = Watir::Browser.new(:firefox, options: options)
      browser
    end
  end
end
