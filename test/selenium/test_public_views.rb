require "selenium"
require "test/unit"

class test_public_views < Test::Unit::TestCase
  def setup
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
      @selenium = Selenium::SeleneseInterpreter.new("localhost", 4444, "*firefox", "http://localhost:4444", 10000);
      @selenium.start
    end
    @selenium.set_context("test_test_public_views", "info")
  end
  
  def teardown
    @selenium.stop unless $selenium
    assert_equal [], @verification_errors
  end
  
  def test_test_public_views
    @selenium.open "/en/communication/links/"
    @selenium.click "link=Articles"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Public | Articles", @selenium.get_title
    assert @selenium.is_text_present("Prof. Josef Gantner, Kunsthistoriker, Basel")
    @selenium.click "link=Kunst und Evolution"
    sleep 0.5
    assert @selenium.is_text_present("kann uns neue Aspekte zum Vers")
    @selenium.click "link=Lectures"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Public | Lectures", @selenium.get_title
    assert @selenium.is_text_present("Seminar, Shanghai Institute of Design, China")
    @selenium.click "link=Exhibitions"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Public | Exhibitions", @selenium.get_title
    assert @selenium.is_text_present("Gallery von Roten, Basel, Switzerland")
  end
end
