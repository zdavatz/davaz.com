#!/usr/bin/env ruby
# Selenium::TestCase -- bbmb.ch -- 22.09.2006 -- hwyss@ywesee.com

$: << File.expand_path("../src", File.dirname(__FILE__))

=begin
if(pid = Kernel.fork)
	at_exit {
		Process.kill('HUP', pid)
	}
else
	path = File.expand_path('selenium-server.jar', File.dirname(__FILE__))
	command = "java -jar #{path}"
	exec(command)
end

require "bbmb/config"
require 'selenium'

$selenium = Selenium::SeleneseInterpreter.new("localhost", 4444,
												"*firefox", BBMB.config.http_server + ":10080", 10000)
start = Time.now
begin
	$selenium.start
rescue Errno::ECONNREFUSED
	sleep 1
	if((Time.now - start) > 15)
		raise
	else
		retry
	end
end
=end

require "util/config"
require "util/davaz"
require 'util/davazapp'
require 'util/db_manager'
require 'util/drbserver'
require 'flexmock'
require 'logger'
require "selenium"
require 'stub/http_server'
require 'stub/db_manager'
require 'stub/yus_server'

module DAVAZ
	module Selenium
class SeleniumWrapper < SimpleDelegator
	def initialize(host, port, browser, server, port2)
		@server = server
		@selenium = ::Selenium::SeleneseInterpreter.new(host, port, browser,
																										server, port2)
		super @selenium
	end
	def open(path)
		@selenium.open(@server + path)
	end
	def type(*args)
		@selenium.type(*args)
	end
end
	end
end

module DAVAZ 
  module Selenium  
module TestCase
  include FlexMock::TestCase
  def setup
		puts "#"*120
		puts "#"*120
		puts self.class
		puts "#"*120
		puts "#"*120
		DAVAZ.config.document_root = File.expand_path('../doc', File.dirname(__FILE__))
		DAVAZ.config.autologin = false
    drb_url = "druby://localhost:10081"
		app = DAVAZ::Util::DavazApp.new
		app.db_manager = DAVAZ::Stub::DbManager.new
		app.yus_server = DAVAZ::Stub::YusServer.new
		@server = DAVAZ::Util::DRbServer.new(app)
    @drb = Thread.new { 
      begin
        @drb_server = DRb.start_service(drb_url, @server) 
      rescue Exception => e
        puts e.class
        puts e.message
        puts e.backtrace
        current.raise(e)
        raise
      end
    }
    @drb.abort_on_exception = true
    @http_server = Stub.http_server(drb_url)
    @webrick = Thread.new { @http_server.start }
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
			@selenium = SeleniumWrapper.new("localhost", 4444, 
				"*chrome /usr/lib/mozilla-firefox/firefox-bin",
				"http://localhost:10080", 10000)
			@selenium.start
    end
    @selenium.set_context("TestCustomers", "info")
		sleep 5
  end
  def teardown
    @selenium.stop unless $selenium
    @http_server.shutdown
		@drb_server.stop_service
    assert_equal [], @verification_errors
  end
	def login
		@selenium.click "link=Login"
		sleep 1
    @selenium.type "login_email", "right@user.ch"
    @selenium.type "login_password", "abcd"
		@selenium.click "document.loginform.login"
    @selenium.wait_for_page_to_load "30000"
	end
end
  end
end
