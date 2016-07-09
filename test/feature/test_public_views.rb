#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 26.09.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'

class TestPublicViews < Test::Unit::TestCase
	include DAVAZ::Selenium::TestCase
  def test_test_public_views
    @selenium.open "/en/communication/links/"
    @selenium.click "link=Articles"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Public | Articles", @selenium.get_title
    assert @selenium.is_text_present("Title of ArtObject 111")
    @selenium.click "link=Title of ArtObject 111"
    sleep 0.5
    assert @selenium.is_text_present("Text of ArtObject 111")
    @selenium.click "link=Lectures"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Public | Lectures", @selenium.get_title
    assert @selenium.is_text_present("Title of ArtObject 113")
    @selenium.click "link=Exhibitions"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Public | Exhibitions", @selenium.get_title
    assert @selenium.is_text_present("Title of ArtObject 115")
  end
end
