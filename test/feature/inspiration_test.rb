#!/usr/bin/env ruby
$:.unshift File.expand_path('..', File.dirname(__FILE__))
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

    # hover and fire_event do not work without click and focus...
    span.focus
    span.click
    span.hover
    span.fire_event('onmouseover')

    dialog = browser.div(id: 'tooltip_tooltip_1_1_dialog')
    assert(dialog.exists?)

    # TODO
    # span.fire_event('onmouseleave')

    # dialog = browser.div(id: 'tooltip_tooltip_1_1_dialog')
    # refute(dialog.exists?)
  end
end
