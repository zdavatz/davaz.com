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
    assert_match('/en/works/movies', browser.url)

    link = browser.a(name: '111-more')
    link.click

    login_as(email: TEST_USER, password: TEST_PASSWORD)

    logout
  end
end
