#!/usr/bin/env ruby
$:.unshift File.expand_path('..', File.dirname(__FILE__))
require 'test_helper'

class TestDrawings < Minitest::Test
  include DaVaz::TestCase
  URL_TO_VISIT = '/en/gallery/tooltips'
  def setup
    startup_server
    browser.visit('/en/personal/work')
    link = browser.link(:id, 'drawings')
    link.click
  end

  def teardown
    logout
    shutdown_server
  end
  def test_admin_drawings_canceling_of_add_new_serie
    login_as(email: TEST_USER, password: TEST_PASSWORD)
    browser.visit(URL_TO_VISIT)
    assert_match(URL_TO_VISIT, browser.url)
    content = browser.text.clone
    [ 'FROM URL',
      'TO URL',
      'http://localhost:11090/en/gallery/art_object/artgroup_id/235/artobject_id/115',
      'Title of ArtObject 111',
      'Text of ArtObject 111',
      "Word\nTitle",
      "From\n115",
      "To\n111",
      ].each do |expected|
      assert(content.index(expected))
    end
    browser.link(:text => 'Links').click
    content = browser.text.clone
    [ 'Title of ArtObject 113',
      'Url of ArtObject 113',
      '01.01.2113',
      ].each do |expected|
      assert(content.index(expected))
    end
    # TODO: Check for occurence of Delete/Add buttons
  end
end
