#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 26.09.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'

class TestPersonalViews < Test::Unit::TestCase
	include DaVaz::Selenium::TestCase
  def test_test_personal_views
    @selenium.open "/en/personal/home"
    @selenium.click "link=HIS LIFE"
    @selenium.wait_for_page_to_load "30000"

		#is there a slideshow?
    assert @selenium.is_text_present("Title of ArtObject 111")

    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS LIFE", @selenium.get_title
    assert @selenium.is_text_present("Early Years")
    assert @selenium.is_text_present("English")
    assert @selenium.is_text_present("Title of ArtObject 115")
    @selenium.click "link=Chinese"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Title of ArtObject 111")
    @selenium.click "link=Hungarian"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Title of ArtObject 113")
    @selenium.click "link=English"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Title of ArtObject 115")
    @selenium.click "link=HIS WORK"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS WORK", @selenium.get_title
    assert @selenium.is_text_present("Title of ArtObject 115")
    @selenium.click "link=HIS INSPIRATION"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS INSPIRATION", @selenium.get_title
    assert @selenium.is_text_present("Title of ArtObject 111")
    @selenium.click "link=HIS FAMILY"
    @selenium.wait_for_page_to_load "30000"

		#is there a slideshow?
    assert @selenium.is_text_present("Title of ArtObject 115")

    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS FAMILY", @selenium.get_title
    assert @selenium.is_text_present("Title of ArtObject 113")
    @selenium.click "link=Next >>"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | THE FAMILY", @selenium.get_title
    assert @selenium.is_text_present("Title of ArtObject 115")
    @selenium.click "link=<< Back"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS FAMILY", @selenium.get_title
    assert @selenium.is_text_present("Title of ArtObject 113")
  end
end
