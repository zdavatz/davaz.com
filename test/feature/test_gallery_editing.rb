#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 04.10.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'
require 'util/image_helper'

class TestGalleryEditing < Test::Unit::TestCase
	include DAVAZ::Selenium::TestCase
	def test_selection_editing
		#prepare for testing
    @selenium.open "/en/gallery/gallery/"
    @selenium.wait_for_page_to_load "30000"
		login
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Movies"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Title of ArtObject 112"
    @selenium.wait_for_page_to_load "30000"

		#adding and removing series
    @selenium.click "link=Add New Serie"
		sleep 2
		@selenium.type "serie_add_form_input", "Test Serie" 
    @selenium.click "submit"
		sleep 2
    assert_equal "ABF", @selenium.get_value("serie_id_select")
		assert_equal "color: blue;", @selenium.get_attribute("link=Remove Selected Serie@style")
    @selenium.click "link=Remove Selected Serie"
		sleep 2
		assert_equal "color: grey;", @selenium.get_attribute("link=Remove Selected Serie@style")
    assert_equal "ABC", @selenium.get_value("serie_id_select")
    @selenium.click "link=Add New Serie"
		sleep 2
		@selenium.type "serie_add_form_input", "Test Serie" 
    @selenium.click "submit"
		sleep 2
    assert_equal "ABF", @selenium.get_value("serie_id_select")

		#adding and removing tools
    @selenium.click "link=Add New Tool"
		sleep 2
		@selenium.type "tool_add_form_input", "Test Tool" 
    @selenium.click "submit"
		sleep 2
    assert_equal "4", @selenium.get_value("tool_id_select")
		assert_equal "color: blue;", @selenium.get_attribute("link=Remove Selected Tool@style")
    @selenium.click "link=Remove Selected Tool"
		sleep 2
		assert_equal "color: grey;", @selenium.get_attribute("link=Remove Selected Tool@style")
    assert_equal "1", @selenium.get_value("tool_id_select")
    @selenium.click "link=Add New Tool"
		sleep 2
		@selenium.type "tool_add_form_input", "Test Tool" 
    @selenium.click "submit"
		sleep 2
    assert_equal "4", @selenium.get_value("tool_id_select")

		#adding and removing materials 
    @selenium.click "link=Add New Material"
		sleep 2
		@selenium.type "material_add_form_input", "Test Material" 
    @selenium.click "submit"
		sleep 2
    assert_equal "4", @selenium.get_value("material_id_select")
		assert_equal "color: blue;", @selenium.get_attribute("link=Remove Selected Material@style")
    @selenium.click "link=Remove Selected Material"
		sleep 2
		assert_equal "color: grey;", @selenium.get_attribute("link=Remove Selected Material@style")
    assert_equal "1", @selenium.get_value("material_id_select")
    @selenium.click "link=Add New Material"
		sleep 2
		@selenium.type "material_add_form_input", "Test Material" 
    @selenium.click "submit"
		sleep 2
    assert_equal "4", @selenium.get_value("material_id_select")

		#can i save the changes?
    @selenium.click "update"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "ABF", @selenium.get_value("serie_id_select")
    assert_equal "4", @selenium.get_value("tool_id_select")
    assert_equal "4", @selenium.get_value("material_id_select")
		assert_equal "color: blue;", @selenium.get_attribute("link=Remove Selected Serie@style")
		assert_equal "color: blue;", @selenium.get_attribute("link=Remove Selected Tool@style")
		assert_equal "color: blue;", @selenium.get_attribute("link=Remove Selected Material@style")
    @selenium.click "link=Back To Overview"
    @selenium.wait_for_page_to_load "30000"

		#cannot remove material, even if there is just one artobject connected
    @selenium.click "link=Title of ArtObject 111"
    @selenium.wait_for_page_to_load "30000"
    @selenium.select "material_id_select", "label=Test Material"
		sleep 1
		assert_equal "color: grey;", @selenium.get_attribute("link=Remove Selected Material@style")

	end
	def test_tag_editing
		#prepare for testing
    @selenium.open "/en/gallery/gallery/"
    @selenium.wait_for_page_to_load "30000"
		login
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Movies"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "link=Title of ArtObject 112"
    @selenium.wait_for_page_to_load "30000"

		#adding and removing series
    @selenium.click "Link=Show All Tags"
		sleep 1
		@selenium.click "Link=Name of Tag 1"
		@selenium.click "Link=Name of Tag 2"
    assert_equal "hislife_show,Name of Tag 1,Name of Tag 2", @selenium.get_value("tags_to_s")
    @selenium.click "update"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "hislife_show,Name of Tag 1,Name of Tag 2", @selenium.get_value("tags_to_s")
	end
  def edit_artobject(aid)
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
		image_file = File.expand_path("../doc/resources/images/#{aid}.png", File.dirname(__FILE__))
		@selenium.type "image_file", image_file
		@selenium.click "//input[@value='Upload Image']"
		sleep 2
		assert @selenium.is_element_present("//img[@name='artobject_image']")
    @selenium.type "title", "Title of ArtObject #{aid} edited"
    @selenium.select "artgroup_id_select", "label=drawings"
    @selenium.select "serie_id_select", "label=Name of Serie ABD"
		@selenium.type "serie_position", "Z"
    @selenium.type "tags_to_s", "Name of Tag 4"
    @selenium.select "tool_id_select", "label=Name of Tool 2"
    @selenium.select "material_id_select", "label=Name of Material 3"
    @selenium.type "size", "10m"
    @selenium.type "date", "10.11.2007"
    @selenium.type "location", "Winterthur"
    @selenium.select "country_id_select", "label=Name of Country D"
    @selenium.type "form_language", "German"
    @selenium.type "document.artobjectform.url", "http://video.google.com/"
    @selenium.type "price", "20"
    @selenium.type "text", "Text of ArtObject #{aid} edited"
    @selenium.click "update"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Title of ArtObject #{aid} edited", @selenium.get_value("title")
    assert_equal "235", @selenium.get_value("artgroup_id_select")
    assert_equal "ABD", @selenium.get_value("serie_id_select")
    assert_equal "Z", @selenium.get_value("serie_position")
    assert_equal "Name of Tag 4", @selenium.get_value("tags_to_s")
    assert_equal "2", @selenium.get_value("tool_id_select")
    assert_equal "3", @selenium.get_value("material_id_select")
    assert_equal "10m", @selenium.get_value("size")
    assert_equal "10.11.2007", @selenium.get_value("date")
    assert_equal "Winterthur", @selenium.get_value("location")
    assert_equal "D", @selenium.get_value("country_id_select")
    assert_equal "German", @selenium.get_value("form_language")
		assert_equal "http://video.google.com/", @selenium.get_value("document.artobjectform.url")
    assert_equal "20", @selenium.get_value("price")
    assert_equal "Text of ArtObject #{aid} edited", @selenium.get_value("text")
		#image_file = File.expand_path("../doc/resources/images/116.png", File.dirname(__FILE__))
		#@selenium.type "image_file", image_file
		#@selenium.click "document.ajax_upload_image_form.ajax_upload_image"
		sleep 2
    @selenium.click "link=Back To Overview"
  end
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
		
		edit_artobject('112')

    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Title of ArtObject 114")
    assert @selenium.is_text_present("Title of ArtObject 115")
    assert @selenium.is_text_present("Title of ArtObject 112 edited")
	end
	def test_edit_movie_artobject
    @selenium.open "/en/works/movies"
    @selenium.wait_for_page_to_load "30000"
		login
    @selenium.wait_for_page_to_load "30000"
=begin
    @selenium.click "112-more"
		sleep 2
		
		edit_artobject('112')

		sleep 2
    assert @selenium.is_text_present("Title of ArtObject 111")
    assert @selenium.is_text_present("Title of ArtObject 112 edited")
=end
    @selenium.click "112-more"
		sleep 2
		@selenium.click("//input[@name='new_art_object']")
		sleep 2
		image_file = File.expand_path("../doc/resources/images/116.png", File.dirname(__FILE__))
		@selenium.type "image_file", image_file
		@selenium.click "//input[@value='Upload Image']"
		sleep 2
		assert @selenium.is_element_present("//img[@name='artobject_image']")
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
    @selenium.type "tags_to_s", "Name of Tag 4"
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
    assert_equal "Name of Tag 4", @selenium.get_value("tags_to_s")
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
    assert_equal "Name of Tag 4", @selenium.get_value("tags_to_s")
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
