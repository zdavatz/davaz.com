#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 26.09.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'

class TestWorksViews < Test::Unit::TestCase
	include DAVAZ::Selenium::TestCase
	def test_stub
    @selenium.open "/en/works/multiples/#112"
    @selenium.wait_for_page_to_load "30000"
	end
  def test_test_works_views
    @selenium.open "/en/communication/links/"
    @selenium.click "link=Drawings"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Drawings", @selenium.get_title
    @selenium.mouse_over "112"
    sleep 1
    assert @selenium.is_text_present("Title of ArtObject 112")
    assert @selenium.is_text_present("Name of Serie ABC, Name of Serie ABD")
    @selenium.click "link=Paintings"
    @selenium.wait_for_page_to_load "30000"
		assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Paintings", @selenium.get_title
    assert @selenium.is_text_present("Title of ArtObject 111")
    @selenium.click "link=Multiples"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Multiples", @selenium.get_title
    assert @selenium.is_text_present("Multiples")
		@selenium.click "//img[@name='111']"
		sleep 2
    @selenium.click "link=Movies"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Movies", @selenium.get_title
    assert @selenium.is_text_present("Title of ArtObject 115")
    @selenium.click "link=more..."
    sleep 5
    begin
        assert @selenium.is_text_present("Text of ArtObject 111")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "paging_next"
    begin
        assert @selenium.is_text_present("Text of ArtObject 112")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "link=Back To Overview"
    sleep 5
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Movies", @selenium.get_title
    @selenium.click "link=Photos"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Photos", @selenium.get_title
    assert @selenium.is_text_present("Title of ArtObject 111")
    @selenium.click "link=Design"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Design", @selenium.get_title
    assert @selenium.is_text_present("Design")
    @selenium.click "link=Schnitzenthesen"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Schnitzenthesen", @selenium.get_title
    assert @selenium.is_text_present("Title of ArtObject 111")
  end
end
