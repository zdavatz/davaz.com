#!/usr/bin/env ruby
$:.unshift File.expand_path('..', File.dirname(__FILE__))
require 'test_helper'

class TestMovies < Minitest::Test
  include DaVaz::TestCase

  def test_painting_then_artist(url= '/')
    browser.cookies.clear
    first_title = 'Da Vaz - Creating a Drawing.'
    artist_title = /Da Vaz - Abstract Artist from Switzerland/i
    SBSM.info "Starting to test #{url}"
    puts "Testing #{url}"
    browser.visit(url)
    saved_size = browser.cookies.to_a.size
    sleep 0.5
    assert_equal(first_title, browser.title, "expect #{first_title} at #{url}")
    counter = 0
    while counter < 30
      if artist_title.match(browser.title)
        assert(true, "At url #{url} found #{artist_title} in #{browser.title}")
        break
      end
      sleep 1;
      browser.images.first.click;  
      counter+=1;
      break if counter > 30
    end
    session_id = browser.cookies['_session_id'][:value]
    new_session_id = nil
    last_link = nil
    [ 'Gallery', 'Guestbook', 'Shop'].each do |link_name|
      last_link = link_name
      link =  browser.link(:text => link_name)
      assert(link.exist? && link.visible?, "Link #{link_name} must exist")
      link.click
      new_session_id = browser.cookies['_session_id'][:value]
      assert_equal(new_session_id, session_id, "Must preserve session_id when visting #{link_name}")
      puts "new_session_id #{new_session_id} == #{new_session_id} #{new_session_id.eql?(session_id)}"
    end
  end

  def test_index_html
    test_painting_then_artist('/index.html')
  end
end
