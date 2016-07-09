#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 26.09.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'

class TestCommunicationViews < Test::Unit::TestCase
	include DAVAZ::Selenium::TestCase
  def test_test_communication_views
    @selenium.open "/en/personal/home/"
    @selenium.click "link=News"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Communication | News", @selenium.get_title
    assert @selenium.is_text_present("Text of ArtObject 111")
    @selenium.click "link=Shop"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Communication | Shop", @selenium.get_title
    assert @selenium.is_text_present("Title of ArtObject 111")
    assert @selenium.is_text_present("ArtGroup of ArtObject 111")
    assert @selenium.is_text_present((111*0.8).to_s)
    assert @selenium.is_text_present((111*0.6).to_s)
    @selenium.click "link=Guestbook"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Communication | Guestbook", @selenium.get_title
    assert @selenium.is_text_present("Text of Guest 1")
    @selenium.click "link=Links"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Communication | Links", @selenium.get_title
    assert @selenium.is_text_present("Url of ArtObject 113")
    assert @selenium.is_text_present("Text of ArtObject 113")
  end
end
