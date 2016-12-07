#!/usr/bin/env ruby
$:.unshift File.expand_path('..', File.dirname(__FILE__))
require 'test_helper'

class TestMovies < Minitest::Test
  include DaVaz::TestCase

  def setup
    browser.visit('/en/personal/work')
    link = browser.a(id: 'movies')
    link.click
  end

  def test_login_then_logout
    login_as(email: TEST_USER, password: TEST_PASSWORD)

    logout
    login_link = browser.link(text: 'Login')
    login_link.wait_until(&:exist?)

    logout_link = browser.link(name: 'logout')
    assert_equal(false, logout_link.exists? && logout_link.visible?, 'Could not log in. Logout-link must no longer be present!')
  end
end
