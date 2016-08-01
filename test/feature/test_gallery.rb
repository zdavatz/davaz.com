#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 26.09.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'

class TestGallery < Test::Unit::TestCase
	include DaVaz::Selenium::TestCase
  def test_test_gallery
    @selenium.open "/en/gallery/gallery/"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Gallery | Gallery", @selenium.get_title
    assert @selenium.is_text_present("Movies | Drawings")
    @selenium.click "link=Name of Serie ABC,"
    sleep 5
    @selenium.click "//a[@name='slideshow' and @onclick=\"toggleShow('show',null,'SlideShow','show-wipearea', null);\"]"
    sleep 5
    @selenium.click "desk"
    sleep 5
    @selenium.click "link=Title of ArtObject 112"
    sleep 5
    begin
        assert @selenium.is_text_present("Text of ArtObject 112")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "paging_last"
    sleep 5
    begin
        assert @selenium.is_text_present("Text of ArtObject 111")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "link=Back To Overview"
    @selenium.click "link=X"
    sleep 5
    assert @selenium.is_text_present("Movies | Drawings")
	end
  def test_test_gallery_search
    @selenium.open "/en/gallery/gallery/"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Gallery | Gallery", @selenium.get_title
    @selenium.type "searchbar", "ABD"
    @selenium.click "search"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Gallery | Search", @selenium.get_title
    assert @selenium.is_text_present("Title of ArtObject 113")
    @selenium.click "link=Title of ArtObject 113"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Gallery | Art Object", @selenium.get_title
    assert @selenium.is_text_present("Text of ArtObject 113")
    @selenium.click "paging_next"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Gallery | Art Object", @selenium.get_title
    assert @selenium.is_text_present("Text of ArtObject 114")
    @selenium.click "paging_last"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Gallery | Art Object", @selenium.get_title
    assert @selenium.is_text_present("Text of ArtObject 113")
    @selenium.click "link=Back To Overview"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Gallery | Search", @selenium.get_title
	end
  def test_test_gallery_search_by_artgroup
    @selenium.open "/en/gallery/gallery/"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Gallery | Gallery", @selenium.get_title
    @selenium.click "link=Movies"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Gallery | Search", @selenium.get_title
    assert @selenium.is_text_present("Title of ArtObject 112")
    @selenium.click "link=Title of ArtObject 112"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Text of ArtObject 112")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "paging_next"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Text of ArtObject 113")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end
end
