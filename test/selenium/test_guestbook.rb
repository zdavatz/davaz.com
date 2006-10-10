#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 26.09.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'

class TestGuestbook < Test::Unit::TestCase
	include DAVAZ::Selenium::TestCase
  def test_test_guestbook
    @selenium.open "/en/personal/home"
    @selenium.click "link=Guestbook"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "//input[@value='New Entry']"
    sleep 0.2
    @selenium.type "name", "TestName"
    @selenium.type "surname", "TestSurname"
    @selenium.type "email", "TestEmail"
    @selenium.type "city", "TestCity"
    @selenium.click "submit_entry"
    sleep 0.5
    assert @selenium.is_text_present("Please enter a Country")
    @selenium.type "country", "TestCountry"
    @selenium.type "messagetxt", "This is a guestbook test entry"
    @selenium.click "submit_entry"
    assert @selenium.is_text_present("Sorry, but your email-address seems to be invalid. Please try again")
    @selenium.type "email", "mhuggler@ywesee.com"
    @selenium.click "submit_entry"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("This is a guestbook test entry")
  end
end
