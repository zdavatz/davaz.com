#!/usr/bin/env ruby
$:.unshift File.expand_path('..', File.dirname(__FILE__))
require 'test_helper'

class TestMovies < Minitest::Test
  include DaVaz::TestCase

  def setup
    startup_server
  end

  def test_login_then_logout
    first_login(browser)
    logout_link = browser.link(name: 'logout')
    assert_equal(true, logout_link.exists? && logout_link.visible?, 'Could not log in. Logout-link must be present!')

    logout
    login_link = browser.link(text: 'Login')
    login_link.wait_until(&:exist?)

    logout_link = browser.link(name: 'logout')
    assert_equal(false, logout_link.exists? && logout_link.visible?, 'Could not log in. Logout-link must no longer be present!')
  end

  def first_login(a_browser)
    a_browser.visit('/en/personal/work')
    link = a_browser.a(id: 'movies')
    link.click
    login_as( {email: TEST_USER, password: TEST_PASSWORD}, a_browser)

    logout_link = a_browser.link(name: 'logout')
    unless logout_link.exists? && logout_link.visible?
      puts "Logout is not shown. Using workAround to go goto Guestbook"
      a_browser.goto(a_browser.links.find{|x| x.text.eql?('Guestbook')}.href)
    end
    logout_link = a_browser.link(name: 'logout')
    assert_equal(true, logout_link.exists? && logout_link.visible?, 'Could not log in. Logout-link must no longer be present!')
  end

  def do_logout(a_browser)
    logout(a_browser)
    login_link = a_browser.link(text: 'Login')
    login_link.wait_until(&:exist?)

    logout_link = a_browser.link(name: 'logout')
    assert_equal(false, logout_link.exists? && logout_link.visible?, 'Could not log in. Logout-link must no longer be present!')
  end

  def test_login_in_to_browsers
    first_login(browser)
    browser_2 = DaVaz::Browser.new(id: 2)
    first_login(browser_2)
    do_logout(browser)
    do_logout(browser_2)
  end
end
