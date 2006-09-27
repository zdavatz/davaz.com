#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 26.09.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'

class TestShop < Test::Unit::TestCase
	include DAVAZ::Selenium::TestCase
  def test_test_shop
    @selenium.open "/en/communication/links"
    @selenium.click "link=Shop"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "article[300]", "2"
    sleep 0.5
    @selenium.click "link=remove all items"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "article[300]", "2"
    sleep 0.5
    assert @selenium.is_text_present("remove item")
    @selenium.click "link=remove item"
    sleep 0.5
    assert !@selenium.is_text_present("remove item")
    sleep 0.5
    @selenium.type "article[302]", "2"
    sleep 0.5
    @selenium.click "order_item"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Please fill out the fields that are marked with red.")
    @selenium.type "name", "TestName"
    @selenium.type "surname", "TestSurname"
    @selenium.type "street", "TestStreet"
    @selenium.type "postal_code", "TestZip"
    @selenium.type "city", "TestCity"
    @selenium.type "country", "TestCountry"
    @selenium.type "email", "TestEmail"
    @selenium.click "order_item"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Your Postal Code seems to be invalid.")
    assert @selenium.is_text_present("Sorry, but your email-address seems to be invalid. Please try again.")
    @selenium.type "postal_code", "8888"
    @selenium.type "email", "mhuggler@ywesee.com"
    @selenium.click "order_item"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Your order has been succesfully sent.")
    @selenium.open "/en/communication/shop"
    @selenium.click "link=001 / The OTHER EYE - a passage through India"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("a creative documentary, duration")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "paging_next"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Events I stumbled into")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "link=Back To Shop"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("WORKS in PROGRESS")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end
end
