#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 04.10.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'
require 'util/image_helper'

class TestLiveEditing < Test::Unit::TestCase
	include DaVaz::Selenium::TestCase
	def live_edit_test1(site, aid)
    @selenium.open "/en/#{site}/"
    @selenium.wait_for_page_to_load "30000"
		login
    assert @selenium.is_text_present("Title of ArtObject #{aid}")
		@selenium.click "#{aid}-title"
		@selenium.type "#{aid}-title", "NEW TITLE"
		@selenium.click "//input[@value='Cancel']"
		sleep 0.5
    assert @selenium.is_text_present("Title of ArtObject #{aid}")
    assert !@selenium.is_text_present("NEW TITLE")
		@selenium.click "#{aid}-title"
		@selenium.type "#{aid}-title", ""
		@selenium.click "//input[@value='Save']"
    assert !@selenium.is_text_present("Title of ArtObject #{aid}")
    assert @selenium.is_text_present("Please click here to edit.")
		@selenium.click "#{aid}-title"
		@selenium.type "#{aid}-title", "NEW TITLE"
		@selenium.click "//input[@value='Save']"
    assert !@selenium.is_text_present("Title of ArtObject #{aid}")
    assert @selenium.is_text_present("NEW TITLE")
		@selenium.click "#{aid}-title"
		@selenium.type "#{aid}-title", ""
		@selenium.click "//input[@value='Save']"
    assert @selenium.is_text_present("Please click here to edit.")
	end
	def live_edit_test2(site, fields) 
    @selenium.open "/en/#{site}/"
    @selenium.wait_for_page_to_load "30000"
		login
		@selenium.click "new_element"
		sleep 0.5
    assert @selenium.is_text_present("Please click here to edit.")
		fields.each { |field|
			@selenium.click "116-#{field}"
			if(field=='date_ch')
				@selenium.type "116-date_ch", "01.01.2116"
			elsif(field=='text')
				@selenium.type "update_value", "#{field.capitalize} of ArtObject 116"
			else
				@selenium.type "116-#{field}", "#{field.capitalize} of ArtObject 116"
			end
			@selenium.click "//input[@value='Save']"
		}
		sleep 0.5
		fields.each { |field|
			if(field=='date_ch')
				assert @selenium.is_text_present("01.01.2116")
			else
				puts field
				assert @selenium.is_text_present("#{field.capitalize} of ArtObject 116")
			end
		}
		@selenium.click "add-image-116"
		sleep 0.5
    assert @selenium.is_text_present("Image File")
		image_file = File.expand_path("../doc/resources/images/116.png", File.dirname(__FILE__))
		@selenium.type "image_file", image_file
		@selenium.click "document.ajax_upload_image_form.ajax_upload_image"
		sleep 2
		@selenium.click "delete-image-116"
		assert /^Do you really want to delete this Image[\s\S]$/ =~ @selenium.get_confirmation
		sleep 2
    assert @selenium.is_element_present("add-image-116")
		@selenium.click "delete-item-116"
		assert /^Do you really want to delete this Item[\s\S]$/ =~ @selenium.get_confirmation
		sleep 0.5
		fields.each { |field|
			if(field=='date_ch')
				assert !@selenium.is_text_present("01.01.2116")
			else
				assert !@selenium.is_text_present("#{field.capitalize} of ArtObject 116")
			end
		}
	end
	def test_his_work1
		live_edit_test1('personal/work', '115')
	end
	def test_his_work2
		live_edit_test2('personal/work', [ 'text' ])
	end
	def test_links1
		live_edit_test1('communication/links', '114')
	end
	def test_links2
		fields = [ 'url', 'date_ch', 'text' ]
		live_edit_test2('communication/links', fields)
	end
	def test_news1
		live_edit_test1('communication/news', '112')
	end
	def test_news2
		fields = [ 'title', 'date_ch', 'text' ]
		live_edit_test2('communication/news', fields)
	end
	def test_gb_live_edit
    @selenium.open "/en/communication/guestbook/"
    @selenium.wait_for_page_to_load "30000"
		login
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "2-name"
    @selenium.type "2-name", "Name of Guest 2 editäd"
    @selenium.click "//input[@value='Save']"
    @selenium.click "2-date_gb"
    @selenium.type "2-date_gb", "01.01.2001"
    @selenium.click "//input[@value='Save']"
    @selenium.click "2-city"
    @selenium.type "2-city", "City of Guest 2 editäd"
    @selenium.click "//input[@value='Save']"
    @selenium.click "2-country"
    @selenium.type "2-country", "Country of Guest 2 editäd"
    @selenium.click "//input[@value='Save']"
    @selenium.click "2-text"
    @selenium.type "update_value", "Text of Guest 2 editäd"
    @selenium.click "//input[@value='Save']"
    assert @selenium.is_text_present("Name of Guest 2 editäd")
    assert @selenium.is_text_present("01.01.2001")
    assert @selenium.is_text_present("City of Guest 2 editäd")
    assert @selenium.is_text_present("Country of Guest 2 editäd")
    assert @selenium.is_text_present("Text of Guest 2 editäd")
    @selenium.click "delete-item-2"
		assert /^Do you really want to delete this Item[\s\S]$/ =~ @selenium.get_confirmation
		sleep 2
    assert !@selenium.is_text_present("Name of Guest 2 editäd")
	end
	def teardown
		DaVaz::Util::ImageHelper.delete_image("116")
		super
	end
end
