#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 26.09.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'

class TestGallery < Test::Unit::TestCase
	include DAVAZ::Selenium::TestCase
  def test_test_gallery
    @selenium.open "/en/gallery/gallery/"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Gallery | Gallery", @selenium.get_title
    assert @selenium.is_text_present("Movies | Multiples | Paintings")
    @selenium.click "link=portrait,"
    sleep 5
    @selenium.click "//a[@name='slideshow' and @onclick=\"toggleShow('show',null,'SlideShow','show-wipearea', null);\"]"
    sleep 5
    @selenium.click "desk"
    sleep 5
    @selenium.click "link=Ursula"
    sleep 5
    begin
        assert @selenium.is_text_present("Drawing made by Dai Yu during")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "paging_next"
    sleep 5
    begin
        assert @selenium.is_text_present("being a spectator")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "link=Back To Overview"
    @selenium.click "link=X"
    sleep 5
    assert @selenium.is_text_present("Movies | Multiples | Paintings")
    @selenium.type "searchbar", "portrait"
    @selenium.click "search"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Gallery | Search", @selenium.get_title
    assert @selenium.is_text_present("handshake with the past")
    @selenium.click "link=handshake with the past"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Gallery | Art Object", @selenium.get_title
    assert @selenium.is_text_present("Adrian Geiges, Then and Now, Shanghai, 3.11.2000")
    @selenium.click "paging_next"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Gallery | Art Object", @selenium.get_title
    assert @selenium.is_text_present("Antonis Tsoukas")
    @selenium.click "paging_last"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Gallery | Art Object", @selenium.get_title
    assert @selenium.is_text_present("Adrian Geiges, Then and Now, Shanghai, 3.11.2000")
    @selenium.click "link=Back To Overview"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Gallery | Search", @selenium.get_title
    @selenium.click "link=Publications"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Gallery | Search", @selenium.get_title
    assert @selenium.is_text_present("Wunderblock A")
    @selenium.click "link=Wunderblock A"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Photographic credits: Bjarne Geiges")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "paging_next"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Photographic credits: Bjarne Geiges")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
  end
end
