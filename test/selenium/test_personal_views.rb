#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 26.09.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'

class TestPersonalViews < Test::Unit::TestCase
	include DAVAZ::Selenium::TestCase
  def test_test_personal_views
    @selenium.open "/en/personal/home"
    @selenium.click "link=HIS LIFE"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS LIFE", @selenium.get_title
    assert @selenium.is_element_present("//span[id('connect-4-1')]")
    assert @selenium.is_text_present("Early Years")
    assert @selenium.is_text_present("English")
    assert @selenium.is_text_present("meets his future friend.")
    @selenium.click "link=Chinese"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Das Sagewerk in den Kopfen")
    @selenium.click "link=Hungarian"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("termet kap a budapesti")
    @selenium.click "link=English"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("While on a late night walk through")
    @selenium.click "link=HIS WORK"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS WORK", @selenium.get_title
    assert @selenium.is_text_present("He refused to go to any Art college")
    @selenium.click "link=HIS INSPIRATION"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS INSPIRATION", @selenium.get_title
    assert @selenium.is_text_present("My heartbeat is my inspiration. It links me to the bangs of life")
    @selenium.click "link=HIS FAMILY"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS FAMILY", @selenium.get_title
    assert @selenium.is_text_present("roots of the family name are found")
    @selenium.click "link=Next >>"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | THE FAMILY", @selenium.get_title
    assert @selenium.is_text_present("The Da Vaz family explores the USA and Canada, crossing the North American continent")
    @selenium.click "link=<< Back"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS FAMILY", @selenium.get_title
    assert @selenium.is_text_present("The family tree starts 1550 in Fanas")
  end
end
