#!/usr/bin/env ruby
# Selenium::TestCase -- bbmb.ch -- 22.09.2006 -- hwyss@ywesee.com

$: << File.expand_path("../src", File.dirname(__FILE__))

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

module DAVAZ 
  module Selenium  
module TestCase
  include FlexMock::TestCase
	class DbManager < FlexMock
	end
  def setup
    #BBMB.logger = Logger.new($stdout)
    #BBMB.logger.level = Logger::DEBUG
    @auth = flexmock('authenticator')
    #BBMB.auth = @auth
    drb_url = "druby://localhost:10081"
		app = DAVAZ::Util::DavazApp.new
		#@db_manager = flexmock('db_manager')
		app.db_manager = DAVAZ::Stub::DbManager.new
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
      @selenium = ::Selenium::SeleneseInterpreter.new("localhost", 
				4444, "*firefox /usr/lib/mozilla-firefox/firefox-bin", 
				"http://localhost:10080", 10000);
      @selenium.start
    end
    @selenium.set_context("TestCustomers", "info")
  end
  def teardown
    @selenium.stop unless $selenium
    @http_server.shutdown
		@drb_server.stop_service
    assert_equal [], @verification_errors
  end
  def login(email, *permissions)
    user = mock_user email, *permissions
    @auth.should_receive(:login).and_return(user)
    @auth.should_ignore_missing
    @selenium.open "/"
    @selenium.type "email", email
    @selenium.type "pass", "test"
    @selenium.click "//input[@name='login']"
    @selenium.wait_for_page_to_load "30000"
    user
  end
  def login_admin
    login "test.admin@bbmb.ch", ['login', 'ch.bbmb.Admin'], 
          ['edit', 'yus.entities']
  end
  def mock_user(email, *permissions)
    user = flexmock(email)
    user.should_receive(:allowed?).and_return { |*pair|
      puts "allowed?(#{pair.join(', ')}"
      permissions.include?(pair)
    }
    user.should_receive(:name).and_return(email)
    user.should_ignore_missing
    user
  end
end
  end
end
