#!/usr/bin/env ruby
$:.unshift File.expand_path('..', File.dirname(__FILE__))
require 'test_helper'

# /gallery/gallery
class TestGallery < Minitest::Test
  include DaVaz::TestCase

  def setup
    browser.visit('/en/gallery/gallery')
  end

  def test_gallery
    assert_match('/en/gallery/gallery', browser.url)

    browser.visit('/en/gallery/gallery/#RACK_ABC')
    assert_match('/en/gallery/gallery/#RACK_ABC', browser.url)

    show_container = Proc.new {
      wait_until { browser.div(id: 'show_container') }
    }
    container = show_container.yield
    widget = wait_until { container.div(id: 'ywesee_widget_rack_0') }
    assert(widget.exists?)

    # serie ABC
    link = wait_until { browser.link(id: 'ABC') }
    link.click

    container = show_container.yield
    widget = wait_until { container.div(id: 'ywesee_widget_rack_1') }
    assert(widget.exists?)

    # serie ABD
    link = wait_until { browser.link(id: 'ABD') }
    link.click

    container = show_container.yield
    widget = wait_until { container.div(id: 'ywesee_widget_rack_2') }
    assert(widget.exists?)
  end
end
