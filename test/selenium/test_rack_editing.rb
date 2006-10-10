#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 04.10.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'
require 'util/image_helper'

class TestRackEditing < Test::Unit::TestCase
	include DAVAZ::Selenium::TestCase
  def test_edit_rack_artobject
    @selenium.open "/en/communication/links"
    @selenium.click "link=Drawings"
    @selenium.wait_for_page_to_load "30000"
		login
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "//img[@name='desk']"
		sleep 2
    @selenium.click "link=Title of ArtObject 112"
		sleep 2
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
		sleep 5
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
    @selenium.click "link=Back To Overview"
		sleep 2
    assert @selenium.is_text_present("Title of ArtObject 111")
    assert @selenium.is_text_present("Title of ArtObject 112 edited")
  end
end
