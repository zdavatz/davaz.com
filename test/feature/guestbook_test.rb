require 'test_helper'

# /communication/shop
class TestGuestbook < Minitest::Test
  include DaVaz::TestCase

  def setup
    browser.visit('/en/personal/work')
    link = browser.a(name: 'guestbook')
    link.click
  end

  def test_guestbook_comment_form_widget
    assert_match('/en/communication/guestbook', browser.url)

    widget = wait_until {
      browser.div(id: 'ywesee_widget_guestbook_0') }
    assert_match(/dojo-attach-point/, widget.html)

    button = browser.input(class: 'new-entry')
    assert_equal('New Entry', button.value)
  end

  def test_guestbook_comment_failures_with_validation_error
    assert_match('/en/communication/guestbook', browser.url)

    button = wait_until { browser.input(class: 'new-entry') }
    button.click

    form = wait_until { browser.form(name: 'stdform') }
    assert(form.exists?)

    button = form.input(type: 'submit')
    button.fire_event('onclick')

    assert_match('/en/communication/guestbook', browser.url)
    message = wait_until { browser.div(class: 'error') }
    assert_equal('Please enter a name.', message.text)
  end

  def test_guestbook_comment
    assert_match('/en/communication/guestbook', browser.url)

    button = wait_until { browser.input(class: 'new-entry') }
    button.click

    form = wait_until { browser.form(name: 'stdform') }
    assert(form.exists?)

    form.text_field(name: 'name').set('John Smith')
    form.text_field(type: 'text', name: 'surname').set('Dr.')
    form.text_field(name: 'email').set('john@example.org')
    form.text_field(name: 'country').set('Schweiz')
    form.text_field(name: 'city').set('Zürich')
    form.textarea(name: 'messagetxt').set('Hoi')
    button = form.input(type: 'submit')
    button.fire_event('onclick')

    assert_match('/en/communication/guestbook', browser.url)
    message = browser.div(class: 'error')
    assert_empty(message.text)
  end
end
