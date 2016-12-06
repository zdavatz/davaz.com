#!/usr/bin/env ruby
$:.unshift File.expand_path('..', File.dirname(__FILE__))
require 'test_helper'

# /gallery/new_art_object
class TestNewArtObject < Minitest::Test
  include DaVaz::TestCase

  def setup
    browser.visit('/en/gallery/gallery')
  end

  def test_new_artobject_creation_with_validation_error
    assert_match('/en/gallery/gallery', browser.url)
    login_as(email: TEST_USER, password:TEST_PASSWORD)

    link = wait_until { browser.link(name: 'new_art_object') }
    link.click

    button = wait_until { browser.element(name: 'save') }
    button.click

    message = wait_until { browser.td(:class, 'processingerror') }
    assert_equal(
      'Please fill out the fields that are marked with red.', message.text)
  end

  def test_new_artobject_creation
    assert_match('/en/gallery/gallery', browser.url)
    login_as(email: TEST_USER, password:TEST_PASSWORD)

    link = wait_until { browser.link(name: 'new_art_object') }
    link.click

    form = wait_until { browser.form(name: 'artobjectform') }
    form.text_field(name: 'title').set('Test New ArtObject')
    form.select_list(name: 'artgroup_id').select('drawings')
    form.select_list(name: 'serie_id').select('Name of Serie ABC')
    form.text_field(name: 'serie_position').set('1')
    form.select_list(name: 'tool_id').select('Name of Tool 2')
    form.select_list(name: 'material_id').select('Name of Material 1')
    form.text_field(name: 'date').set('01.01.2016')
    form.select_list(name: 'country_id').select('Name of Country CH')

    frame = wait_until { browser.iframe(:index, 0) }
    editor = frame.div(:id, 'dijitEditorBody')
    editor.focus
    editor.send_keys(:delete) # there is a strange blank space
    editor.send_keys('NEW ART OBJECT')
    editor.send_keys(:tab)
    assert_equal('NEW ART OBJECT', editor.text)

    button = browser.element(name: 'save')
    button.click

    refute(browser.td(:class, 'processingerror').exists?)
  end
end
