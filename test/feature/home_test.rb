#!/usr/bin/env ruby
$:.unshift File.expand_path('..', File.dirname(__FILE__))
require 'test_helper'

class TestMovies < Minitest::Test
  include DaVaz::TestCase

  def test_painting_then_artist(url= '/')
    first_title = 'Da Vaz - Creating a Drawing.'
    artist_title = /Da Vaz - Abstract Artist from Switzerland/i
    SBSM.info "Starting to test #{url}"
    puts "Testing #{url}"
    browser.visit(url)
    sleep 0.5
    assert_equal(first_title, browser.title, "expect #{first_title} at #{url}")
    counter = 0
    while counter < 30
      if artist_title.match(browser.title)
        assert(true, "At url #{url} found #{artist_title} in #{browser.title}")
        return
      end
      sleep 1;
      browser.images.first.click;  
      counter+=1;
      break if counter > 30
    end
    assert(false, "At url #{url} did not find #{artist_title} in #{browser.title}")
  end

  def test_index_html
    test_painting_then_artist('/index.html')
  end
end
