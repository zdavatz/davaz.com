#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 26.09.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'

class TestCommunicationViews < Test::Unit::TestCase
	include DAVAZ::Selenium::TestCase
  def test_test_communication_views
    @selenium.open "/en/personal/home/"
    @selenium.click "link=News"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Communication | News", @selenium.get_title
    assert @selenium.is_text_present("Master Class for young Russian Filmmakers")
    @selenium.click "link=Guestbook"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Communication | Guestbook", @selenium.get_title
    assert @selenium.is_text_present("I am affiliated with a Kazakhstan adoption agency and feel that your work will help many MANY children see first hand where they have come from")
    @selenium.click "link=Shop"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Communication | Shop", @selenium.get_title
    assert @selenium.is_text_present("002 / TRAPPED REALITY")
    @selenium.click "link=Links"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Communication | Links", @selenium.get_title
    assert @selenium.is_text_present("chinese art that fits to buy")
  end
end
