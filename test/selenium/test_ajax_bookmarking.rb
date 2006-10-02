#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 26.09.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'

class TestAjaxBookmarking < Test::Unit::TestCase
	include DAVAZ::Selenium::TestCase
	def test_test_ajax_bookmarking_export
		@selenium.open "/en/gallery/gallery/#Desk_ABC"
		sleep 2
		begin
				assert @selenium.is_text_present("Title of ArtObject 123")
		rescue Test::Unit::AssertionFailedError
				@verification_errors << $!
		end
		@selenium.click "//a[@name='slideshow' and @onclick=\"toggleShow('show',null,'SlideShow','show-wipearea', null);\"]"
		sleep 2
		begin
				assert @selenium.is_text_present("024 / CITY in MAKING")
		rescue Test::Unit::AssertionFailedError
				@verification_errors << $!
		end
		@selenium.open "/en/works/drawings/#Desk_AAH"
		sleep 2
		begin
				assert @selenium.is_text_present("pianokaijak, opus 2")
		rescue Test::Unit::AssertionFailedError
				@verification_errors << $!
		end
		@selenium.click "link=Heuhaufen,"
		sleep 2
		begin
				assert /Desk_ABM/ =~ @selenium.get_location
		rescue Test::Unit::AssertionFailedError
				@verification_errors << $!
		end
	end
end
