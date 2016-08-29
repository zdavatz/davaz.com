require 'test_helper'

# /personal/work
class TestWork < Minitest::Test
  include DaVaz::TestCase

  def setup
    browser.visit('/en/personal/work')
  end

  def test_gallery
    assert_match('/en/personal/work', browser.url)

    span = wait_until { browser.span(class: 'tooltip') }
    assert_equal('tooltip_1_1', span.attribute_value(:id))

    sleep(1)

    span.hover
    span.fire_event('onmouseover')

    dialog = wait_until { browser.div(id: 'tooltip_tooltip_1_1_dialog') }
    assert(dialog.exists?)

    tooltip = wait_until { browser.div(id: 'tooltip_1_1_dropdown') }
    assert(tooltip.exists?)
  end
end
