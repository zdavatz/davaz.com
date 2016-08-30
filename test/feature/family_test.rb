require 'test_helper'

# /personal/family
class TestFamily < Minitest::Test
  include DaVaz::TestCase

  def setup
    browser.visit('/en/personal/family')
  end

  def test_family_slide_show_widget
    assert_match('/en/personal/family', browser.url)

    widget = wait_until { browser.div(:id, 'ywesee_widget_slide_0') }
    assert_equal('ywesee_widget_slide_0', widget.attribute_value('widgetid'))

    control = widget.img(class: 'slide-control-image')
    assert_match(/images\/global\/pause\.gif$/, control.attribute_value('src'))
  end

  def test_family_next_link
    assert_match('/en/personal/family', browser.url)

    link = wait_until { browser.a(name: 'the_family') }
    assert_equal('Next >>', link.text)
    link.click

    assert_match('/en/personal/the_family', browser.url)

    back = wait_until { browser.div(class: 'back-link') }
    link = back.a(name: 'family')
    assert_equal('<< Back', link.text)
    link.click

    assert_match('/en/personal/family', browser.url)
  end
end
