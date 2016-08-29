require 'test_helper'

# /personal/inspiration
class InspirationTest < Minitest::Test
  include DaVaz::TestCase

  def setup
    browser.visit('/en/personal/inspiration')
  end

  def test_tooltips_on_textblock
    text = wait_until { browser.div(class: 'intro-text') }
    span = text.element(id: 'tooltip_1_1')

    span.hover
    span.fire_event('onmouseover')

    dialog = browser.div(id: 'tooltip_tooltip_1_1_dialog')
    assert(dialog.exists?)


    # TODO
    span.fire_event('onmouseleave')

    dialog = browser.div(id: 'tooltip_tooltip_1_1_dialog')
    refute(dialog.exists?)
  end

  #def test_test_personal_views
  #  @selenium.open "/en/personal/home"
  #  @selenium.click "link=HIS LIFE"
  #  @selenium.wait_for_page_to_load "30000"

  #  #is there a slideshow?
  #  assert @selenium.is_text_present("Title of ArtObject 111")

  #  assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS LIFE", @selenium.get_title
  #  assert @selenium.is_text_present("Early Years")
  #  assert @selenium.is_text_present("English")
  #  assert @selenium.is_text_present("Title of ArtObject 115")
  #  @selenium.click "link=Chinese"
  #  @selenium.wait_for_page_to_load "30000"
  #  assert @selenium.is_text_present("Title of ArtObject 111")
  #  @selenium.click "link=Hungarian"
  #  @selenium.wait_for_page_to_load "30000"
  #  assert @selenium.is_text_present("Title of ArtObject 113")
  #  @selenium.click "link=English"
  #  @selenium.wait_for_page_to_load "30000"
  #  assert @selenium.is_text_present("Title of ArtObject 115")
  #  @selenium.click "link=HIS WORK"
  #  @selenium.wait_for_page_to_load "30000"
  #  assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS WORK", @selenium.get_title
  #  assert @selenium.is_text_present("Title of ArtObject 115")
  #  @selenium.click "link=HIS INSPIRATION"
  #  @selenium.wait_for_page_to_load "30000"
  #  assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS INSPIRATION", @selenium.get_title
  #  assert @selenium.is_text_present("Title of ArtObject 111")
  #  @selenium.click "link=HIS FAMILY"
  #  @selenium.wait_for_page_to_load "30000"

  #  #is there a slideshow?
  #  assert @selenium.is_text_present("Title of ArtObject 115")

  #  assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS FAMILY", @selenium.get_title
  #  assert @selenium.is_text_present("Title of ArtObject 113")
  #  @selenium.click "link=Next >>"
  #  @selenium.wait_for_page_to_load "30000"
  #  assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | THE FAMILY", @selenium.get_title
  #  assert @selenium.is_text_present("Title of ArtObject 115")
  #  @selenium.click "link=<< Back"
  #  @selenium.wait_for_page_to_load "30000"
  #  assert_equal "Da Vaz - Abstract Artist from Switzerland | Personal | HIS FAMILY", @selenium.get_title
  #  assert @selenium.is_text_present("Title of ArtObject 113")
  #end
end
