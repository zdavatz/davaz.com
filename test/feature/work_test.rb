#!/usr/bin/env ruby
$:.unshift File.expand_path('..', File.dirname(__FILE__))
require 'test_helper'

# /personal/work
class TestWork < Minitest::Test
  include DaVaz::TestCase

  def setup
    browser.visit('/en/personal/work')
  end

  def test_gallery
    assert_match('/en/personal/work', browser.url)

    span =browser.span(class: 'tooltip')
    span.wait_until(&:present?).text
    assert_equal('tooltip_4_1', span.attribute_value(:id))

    span.focus
    span.click
    span.hover
    span.fire_event('onmouseover')
    sleep(1)

    dialog = browser.div(id: 'tooltip_tooltip_4_1_dialog')
    dialog.wait_until(&:present?)
    assert(dialog.exists?)

    tooltip =browser.div(id: 'tooltip_4_1_dropdown').wait_until(&:present?)
    assert(tooltip.exists?)
  end
end
