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
    @selenium.type "article[111]", "2"
    @selenium.type "article[112]", "2"
    @selenium.type "article[113]", "2"
    sleep 3
    assert @selenium.is_text_present("CHF 222.-")
    assert @selenium.is_text_present("CHF 224.-")
    assert @selenium.is_text_present("CHF 226.-")
    assert @selenium.is_text_present("CHF 672.- / $ 534.- / € 400.-")
    @selenium.click "link=remove all items"
    sleep 3
    assert !@selenium.is_text_present("CHF 222.-")
    assert !@selenium.is_text_present("CHF 224.-")
    assert !@selenium.is_text_present("CHF 226.-")
    assert !@selenium.is_text_present("CHF 672.- / $ 534.- / € 400.-")
    @selenium.type "article[113]", "2"
    @selenium.type "article[114]", "2"
    sleep 3
    assert @selenium.is_text_present("CHF 226.-")
    @selenium.type "article[113]", "4"
    @selenium.type "article[114]", "0"
		sleep 3
    assert @selenium.is_text_present("CHF 452.-")
    assert @selenium.is_text_present("CHF 452.- / $ 360.- / € 268.-")
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
	end
	def test_test_shop2
    @selenium.open "/en/communication/shop"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Title of ArtObject 112"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Text of ArtObject 112")
    @selenium.click "paging_next"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Text of ArtObject 113")
    @selenium.click "link=Back To Shop"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Title of ArtObject 114")
  end
end
