#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 04.10.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'
require 'util/image_helper'

class TestLiveEditing < Test::Unit::TestCase
	include DAVAZ::Selenium::TestCase
	def test_edit_title
    @selenium.open "/en/communication/links/"
    @selenium.wait_for_page_to_load "30000"
		login
    assert @selenium.is_text_present("Title of ArtObject 114")
		@selenium.click "114-title"
		@selenium.type "114-title", "NEW TITLE"
		@selenium.click "//input[@value='Cancel']"
		sleep 0.5
    assert @selenium.is_text_present("Title of ArtObject 114")
    assert !@selenium.is_text_present("NEW TITLE")
		@selenium.click "114-title"
		@selenium.type "114-title", ""
		@selenium.click "//input[@value='Save']"
    assert !@selenium.is_text_present("Title of ArtObject 114")
    assert @selenium.is_text_present("Please click here to edit.")
		@selenium.click "114-title"
		@selenium.type "114-title", "NEW TITLE"
		@selenium.click "//input[@value='Save']"
    assert !@selenium.is_text_present("Title of ArtObject 114")
    assert @selenium.is_text_present("NEW TITLE")
	end
	def test_delete_and_add_item
    @selenium.open "/en/communication/links/"
    @selenium.wait_for_page_to_load "30000"
		login
		@selenium.click "new_element"
		sleep 0.5
    assert @selenium.is_text_present("Please click here to edit.")
		@selenium.click "116-title"
		@selenium.type "116-title", "Title of NewArtobject"
		@selenium.click "//input[@value='Save']"
		sleep 0.5
    assert @selenium.is_text_present("Title of NewArtobject")
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
    assert !@selenium.is_text_present("Title of NewArtobject")
	end
	def teardown
		DAVAZ::Util::ImageHelper.delete_image("116")
		super
	end
end
