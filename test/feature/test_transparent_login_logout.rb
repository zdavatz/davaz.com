#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 03.10.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'

class TestTransparentLoginLogout < Test::Unit::TestCase
	include DaVaz::Selenium::TestCase
	def test_transparent_login_logout
    @selenium.open "/en/communication/links/"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Communication | Links", @selenium.get_title
		@selenium.click "link=Login"
    @selenium.type "login_email", "wrong_user"
    @selenium.type "login_password", "abcd"
		@selenium.click "document.loginform.login"
    sleep 1
    assert @selenium.is_text_present("Login failed! Invalid Username or Password. Please try again.")
    assert !@selenium.is_text_present("Logout")
    @selenium.type "login_email", "right@user.ch"
		@selenium.click "document.loginform.login"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Logout")
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Communication | Links", @selenium.get_title
		@selenium.click "link=Logout"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Login")
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Communication | Links", @selenium.get_title
	end
	def test_transparent_login_logout
    @selenium.open "/en/works/drawings/#Desk_ABD"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Drawings", @selenium.get_title
    assert @selenium.is_text_present("Tool of ArtObject 114")
		@selenium.click "link=Login"
		sleep 2
    @selenium.type "login_email", "right@user.ch"
    @selenium.type "login_password", "abcd"
		@selenium.click "document.loginform.login"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Drawings", @selenium.get_title
    assert @selenium.is_text_present("Title of ArtObject 114")
    assert @selenium.is_text_present("Logout")
		@selenium.click "link=Logout"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Drawings", @selenium.get_title
    assert @selenium.is_text_present("Tool of ArtObject 114")
    assert @selenium.is_text_present("Login")
	end
end
