require 'test_helper'

# /personal/work
class TestWork < Minitest::Test
  include DaVaz::TestCase

  def setup
    browser.visit('/en/personal/work')
  end

  def test_gallery
    assert_match('/en/personal/work', browser.url)

    text = wait_until { browser.div(class: 'intro-text') }
    span = text.element(id: 'tooltip_1_1')
    # TODO
    span.fire_event(:onmouseover)
    text = wait_until { browser.div(class: 'intro-text') }

    dialog = text.div(id: 'tooltip_tooltip_1_1_dialog')
    assert(dialog.exists?)
  end
end
