#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 04.10.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'
require 'util/image_helper'

class TestGalleryEditing < Test::Unit::TestCase
	include DAVAZ::Selenium::TestCase
  def test_edit_gallery_artobject
    @selenium.open "/en/personal/home"
    @selenium.click "link=Gallery"
    @selenium.wait_for_page_to_load "30000"
		login
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Movies"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Title of ArtObject 112"
    @selenium.wait_for_page_to_load "30000"
		assert @selenium.is_element_present("//img[@name='artobject_image']")
    @selenium.choose_cancel_on_next_confirmation
    @selenium.click "delete_image"
    assert /^Do you really want to delete this image[\s\S]$/ =~ @selenium.get_confirmation
		sleep 2
		assert @selenium.is_element_present("//img[@name='artobject_image']")
    @selenium.click "delete_image"
    assert /^Do you really want to delete this image[\s\S]$/ =~ @selenium.get_confirmation
		sleep 2
		assert !@selenium.is_element_present("//img[@name='artobject_image']")
		image_file = File.expand_path("../doc/resources/images/112.png", File.dirname(__FILE__))
		@selenium.type "image_file", image_file
		@selenium.click "//input[@value='Upload Image']"
		sleep 2
		assert @selenium.is_element_present("//img[@name='artobject_image']")
    @selenium.type "title", "Title of ArtObject 112 edited"
    @selenium.select "artgroup_id_select", "label=drawings"
    @selenium.select "serie_id_select", "label=Name of Serie ABD"
		@selenium.type "serie_position", "Z"
    @selenium.type "tags_to_s", "one"
    @selenium.select "tool_id_select", "label=Name of Tool 2"
    @selenium.select "material_id_select", "label=Name of Material 3"
    @selenium.type "size", "10m"
    @selenium.type "date", "10.11.2007"
    @selenium.type "location", "Winterthur"
    @selenium.select "country_id_select", "label=Name of Country D"
    @selenium.type "form_language", "German"
    @selenium.type "document.artobjectform.url", "http://video.google.com/"
    @selenium.type "price", "20"
    @selenium.type "text", "Text of ArtObject 112 edited"
    @selenium.click "update"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Title of ArtObject 112 edited", @selenium.get_value("title")
    assert_equal "235", @selenium.get_value("artgroup_id_select")
    assert_equal "ABD", @selenium.get_value("serie_id_select")
    assert_equal "Z", @selenium.get_value("serie_position")
    assert_equal "Name of Tag one", @selenium.get_value("tags_to_s")
    assert_equal "2", @selenium.get_value("tool_id_select")
    assert_equal "3", @selenium.get_value("material_id_select")
    assert_equal "10m", @selenium.get_value("size")
    assert_equal "10.11.2007", @selenium.get_value("date")
    assert_equal "Winterthur", @selenium.get_value("location")
    assert_equal "D", @selenium.get_value("country_id_select")
    assert_equal "German", @selenium.get_value("form_language")
		assert_equal "http://video.google.com/", @selenium.get_value("document.artobjectform.url")
    assert_equal "20", @selenium.get_value("price")
    assert_equal "Text of ArtObject 112 edited", @selenium.get_value("text")
		#image_file = File.expand_path("../doc/resources/images/116.png", File.dirname(__FILE__))
		#@selenium.type "image_file", image_file
		#@selenium.click "document.ajax_upload_image_form.ajax_upload_image"
		sleep 2
    @selenium.click "link=Back To Overview"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Title of ArtObject 114")
    assert @selenium.is_text_present("Title of ArtObject 115")
    assert @selenium.is_text_present("Title of ArtObject 112 edited")
  end
  def test_new_gallery_artobject
    @selenium.open "/en/personal/home"
    @selenium.click "link=Gallery"
    @selenium.wait_for_page_to_load "30000"
		login
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=New Art Object"
    @selenium.wait_for_page_to_load "30000"
		assert !@selenium.is_element_present("//img[@name='artobject_image']")
    @selenium.select "artgroup_id_select", "label=drawings"
    @selenium.select "serie_id_select", "label=Name of Serie ABD"
		@selenium.type "serie_position", "Z"
    @selenium.type "tags_to_s", "one"
    @selenium.select "tool_id_select", "label=Name of Tool 2"
    @selenium.select "material_id_select", "label=Name of Material 3"
    @selenium.type "size", "10m"
    @selenium.type "date", "10.11.2007"
    @selenium.type "location", "Winterthur"
    @selenium.select "country_id_select", "label=Name of Country D"
    @selenium.type "form_language", "German"
    @selenium.type "document.artobjectform.url", "http://video.google.com/"
    @selenium.type "price", "20"
    @selenium.type "text", "Text of ArtObject 116"
    @selenium.click "save"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Please fill out the fields that are marked with red.")
    assert_equal "", @selenium.get_value("title")
    assert_equal "235", @selenium.get_value("artgroup_id_select")
    assert_equal "ABD", @selenium.get_value("serie_id_select")
    assert_equal "Z", @selenium.get_value("serie_position")
    assert_equal "one", @selenium.get_value("tags_to_s")
    assert_equal "2", @selenium.get_value("tool_id_select")
    assert_equal "3", @selenium.get_value("material_id_select")
    assert_equal "10m", @selenium.get_value("size")
    assert_equal "10.11.2007", @selenium.get_value("date")
    assert_equal "Winterthur", @selenium.get_value("location")
    assert_equal "D", @selenium.get_value("country_id_select")
    assert_equal "German", @selenium.get_value("form_language")
		assert_equal "http://video.google.com/", @selenium.get_value("document.artobjectform.url")
    assert_equal "20", @selenium.get_value("price")
    assert_equal "Text of ArtObject 116", @selenium.get_value("text")
    @selenium.type "title", "Title of ArtObject 116"
    @selenium.click "save"
    @selenium.wait_for_page_to_load "30000"

		assert_equal "Title of ArtObject 116", @selenium.get_value("title")
    assert_equal "235", @selenium.get_value("artgroup_id_select")
    assert_equal "ABD", @selenium.get_value("serie_id_select")
    assert_equal "Z", @selenium.get_value("serie_position")
    assert_equal "Name of Tag one", @selenium.get_value("tags_to_s")
    assert_equal "2", @selenium.get_value("tool_id_select")
    assert_equal "3", @selenium.get_value("material_id_select")
    assert_equal "10m", @selenium.get_value("size")
    assert_equal "10.11.2007", @selenium.get_value("date")
    assert_equal "Winterthur", @selenium.get_value("location")
    assert_equal "D", @selenium.get_value("country_id_select")
    assert_equal "German", @selenium.get_value("form_language")
		assert_equal "http://video.google.com/", @selenium.get_value("document.artobjectform.url")
    assert_equal "20", @selenium.get_value("price")
    assert_equal "Text of ArtObject 116", @selenium.get_value("text")

    @selenium.click "link=Back To Overview"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Title of ArtObject 114")
    assert @selenium.is_text_present("Title of ArtObject 115")
    assert @selenium.is_text_present("Title of ArtObject 116")
    @selenium.click "link=Title of ArtObject 116"
    @selenium.wait_for_page_to_load "30000"
    @selenium.choose_cancel_on_next_confirmation
		@selenium.click "//input[@value='Delete Item']"
    assert /^Do you really want to delete this artobject[\s\S]$/ =~ @selenium.get_confirmation
		sleep 2
    assert_equal "Title of ArtObject 116", @selenium.get_value("title")
		image_file = File.expand_path("../doc/resources/images/116.png", File.dirname(__FILE__))
		@selenium.type "image_file", image_file
		@selenium.click "//input[@value='Upload Image']"
		sleep 2
		assert @selenium.is_element_present("//img[@name='artobject_image']")
		@selenium.click "//input[@value='Delete Item']"
    assert /^Do you really want to delete this artobject[\s\S]$/ =~ @selenium.get_confirmation
    @selenium.wait_for_page_to_load "30000"
    assert !@selenium.is_text_present("Title of ArtObject 116")
  end
end
