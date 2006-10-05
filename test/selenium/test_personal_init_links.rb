#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 26.09.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'

class TestPersonalInitLinks < Test::Unit::TestCase
	include DAVAZ::Selenium::TestCase
  def test_test_personal_init_links_pic_inspiration
    @selenium.open "/en/personal/home"
    @selenium.click "pic_inspiration"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS INSPIRATION", @selenium.get_title
    @selenium.click "link=Home"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | Home", @selenium.get_title
    @selenium.click "pic_family"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS FAMILY", @selenium.get_title
    @selenium.click "link=Home"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | Home", @selenium.get_title
    @selenium.click "signature"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS WORK", @selenium.get_title
    @selenium.click "link=Home"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | Home", @selenium.get_title
    @selenium.click "link=News"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Communication | News", @selenium.get_title
    @selenium.click "link=Home"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | Home", @selenium.get_title
    @selenium.click "link=Links"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Communication | Links", @selenium.get_title
    @selenium.click "link=Home"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | Home", @selenium.get_title
    @selenium.click "link=Gallery"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Gallery | Gallery", @selenium.get_title
    @selenium.click "link=Home"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | Home", @selenium.get_title
    @selenium.click "link=Movies"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Movies", @selenium.get_title
    @selenium.click "link=Home"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | Home", @selenium.get_title
  end
end
