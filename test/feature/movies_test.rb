require 'test_helper'

# /works/movies
class TestMovies < Minitest::Test
  include DaVaz::TestCase

  def setup
    browser.visit('/en/personal/work')
    link = browser.link(:id, 'movies')
    link.click
  end

  def test_movies_movie_entry_has_clickable_more_link
    assert_match('/en/works/movies', browser.url)

    list = browser.div(:id, 'movies_list')
    link = list.div(:id, 'movie_details_link_111')
    more = link.div(:class, 'more-link')
    link = more.a(:name, '111-more')

    assert_equal('More...', link.text)

    onclick = link.attribute_value('onclick')
    assert_match(/movies_gallery_view/, onclick)
    assert_match(/movies_list/,         onclick)

    link.click
    view = wait_until { browser.div(:id, 'movies_gallery_view') }
    assert_equal('Back to overview', view.a(:name, 'back_to_overview').text)
    assert_match('/en/works/movies/#111', browser.url)
  end

  #def test_stub
  #  @selenium.open "/en/works/multiples/#112"
  #  @selenium.wait_for_page_to_load "30000"
  #end

  #def test_test_works_views
  #  @selenium.open "/en/communication/links/"
  #  @selenium.click "link=Drawings"
  #  @selenium.wait_for_page_to_load "30000"
  #  assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Drawings", @selenium.get_title
  #  @selenium.mouse_over "112"
  #  sleep 1
  #  assert @selenium.is_text_present("Title of ArtObject 112")
  #  assert @selenium.is_text_present("Name of Serie ABC, Name of Serie ABD")
  #  @selenium.click "link=Paintings"
  #  @selenium.wait_for_page_to_load "30000"
  #  assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Paintings", @selenium.get_title
  #  assert @selenium.is_text_present("Title of ArtObject 111")
  #  @selenium.click "link=Multiples"
  #  @selenium.wait_for_page_to_load "30000"
  #  assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Multiples", @selenium.get_title
  #  assert @selenium.is_text_present("Multiples")
  #  @selenium.click "//img[@name='111']"
  #  sleep 2
  #  @selenium.click "link=Movies"
  #  @selenium.wait_for_page_to_load "30000"
  #  assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Movies", @selenium.get_title
  #  assert @selenium.is_text_present("Title of ArtObject 115")
  #  @selenium.click "link=more..."
  #  sleep 5
  #  begin
  #      assert @selenium.is_text_present("Text of ArtObject 111")
  #  rescue Test::Unit::AssertionFailedError
  #      @verification_errors << $!
  #  end
  #  @selenium.click "paging_next"
  #  begin
  #      assert @selenium.is_text_present("Text of ArtObject 112")
  #  rescue Test::Unit::AssertionFailedError
  #      @verification_errors << $!
  #  end
  #  @selenium.click "link=Back To Overview"
  #  sleep 5
  #  assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Movies", @selenium.get_title
  #  @selenium.click "link=Photos"
  #  @selenium.wait_for_page_to_load "30000"
  #  assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Photos", @selenium.get_title
  #  assert @selenium.is_text_present("Title of ArtObject 111")
  #  @selenium.click "link=Design"
  #  @selenium.wait_for_page_to_load "30000"
  #  assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Design", @selenium.get_title
  #  assert @selenium.is_text_present("Design")
  #  @selenium.click "link=Schnitzenthesen"
  #  @selenium.wait_for_page_to_load "30000"
  #  assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Schnitzenthesen", @selenium.get_title
  #  assert @selenium.is_text_present("Title of ArtObject 111")
  #end
end
