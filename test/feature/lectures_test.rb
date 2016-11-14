#!/usr/bin/env ruby
$:.unshift File.expand_path('..', File.dirname(__FILE__))
require 'test_helper'

# /public/lectures
class TestLectures < Minitest::Test
  include DaVaz::TestCase

  def setup
    browser.visit('/en/public/lectures')
  end

  def test_lectures_toggle_hidden_dev_links
    assert_match('/en/public/lectures', browser.url)

    block = wait_until { browser.div(class: 'block-text') }

    link = block.a(name: 'Text')
    assert_equal('Text', link.text)
    assert_match(/toggleHiddenDiv/, link.attribute_value('onclick'))
    link.click

    div = wait_until { browser.div(id: '2_hidden_div') }

    assert_match(/display:\sblock;/, div.attribute_value('style'))
    assert(div.a(name: 'hide_link').exists?)
  end

  def test_lectures_tooltips
    assert_match('/en/public/lectures', browser.url)

    span = wait_until { browser.span(class: 'tooltip') }
    assert_equal('tooltip_3_1', span.attribute_value(:id))

    sleep(1)

    span.hover
    span.fire_event('onmouseover')

    dialog = wait_until { browser.div(id: 'tooltip_tooltip_3_1_dialog') }
    assert(dialog.exists?)

    tooltip = wait_until { browser.div(id: 'tooltip_3_1_dropdown') }
    assert(tooltip.exists?)
  end
end
