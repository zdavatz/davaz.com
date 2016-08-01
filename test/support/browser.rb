require 'watir-webdriver'

module DaVaz
  class Browser < SimpleDelegator

    def initialize(args)
      @browser = Watir::Browser.new(*args)
      super @browser
    end

    def visit(path)
      @browser.goto(TEST_SRV_URI.to_s + path)
    end
  end
end
