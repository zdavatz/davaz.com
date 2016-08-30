require 'test_helper'

# /works/movies
class TestMovies < Minitest::Test
  include DaVaz::TestCase

  def setup
    browser.visit('/en/personal/work')
    link = browser.a(id: 'movies')
    link.click
  end

  def test_movies_movie_entry_clickable_more_link
    assert_match('/en/works/movies', browser.url)

    list = browser.div(id: 'movies_list')
    link = list.div(id: 'movie_details_link_111')
    more = link.div(class: 'more-link')
    link = more.a(name: '111-more')

    assert_equal('More...', link.text)

    onclick = link.attribute_value('onclick')
    assert_match(/movies_gallery_view/, onclick)
    assert_match(/movies_list/,         onclick)

    link.click
    view = wait_until { browser.div(id: 'movies_gallery_view') }

    sleep(1)

    assert_equal('Back To Overview', view.a(name: 'back_to_overview').text)
    assert_match('/en/works/movies/#111', browser.url)
  end

  def test_movies_show_a_thumbnail_of_its_movie
    assert_match('/en/works/movies', browser.url)

    link = browser.a(name: '111-more')
    link.click

    view = wait_until { browser.div(id: 'movies_gallery_view') }
    assert_match('/en/works/movies/#111', browser.url)

    image = view.img(id: 'artobject_image_111')
    assert_match(
      '/resources/uploads/images/1/111.jpeg', image.attribute_value('src'))
  end

  def test_movies_pagination
    assert_match('/en/works/movies', browser.url)

    link = browser.a(name: '111-more')
    link.click

    view = wait_until { browser.div(:id, 'movies_gallery_view') }
    assert_match('/en/works/movies/#111', browser.url)
    pager = view.div(:id, 'artobject_pager')
    assert_match('Item 1 of 5', pager.text)

    next_link = pager.a(name: 'paging_next')
    next_link.fire_event('onclick')

    view = wait_until { browser.div(id: 'movies_gallery_view') }
    assert_match('/en/works/movies/#112', browser.url)
    pager = view.div(id: 'artobject_pager')
    assert_match('Item 2 of 5', pager.text)

    prev_link = pager.a(name: 'paging_last')
    prev_link.fire_event('onclick')

    view = wait_until { browser.div(id: 'movies_gallery_view') }
    assert_match('/en/works/movies/#111', browser.url)
    pager = view.div(id: 'artobject_pager')
    assert_match('Item 1 of 5', pager.text)
  end

  def test_admin_movies_update_description_text_by_wysiwyg_editor
    assert_match('/en/works/movies', browser.url)

    link = browser.a(name: '111-more')
    link.click

    login_as(email: 'right@user.ch', password: 'abcd')

    frame = wait_until { browser.iframe(index: 0) }
    editor = frame.div(id: 'dijitEditorBody')
    editor.focus
    sleep(1)
    editor.send_keys('UPDATED: ')
    editor.send_keys(:tab)
    assert_equal('UPDATED: Text of ArtObject 111', editor.text)

    # TODO :'(
    button = browser.element(name: 'update')
    button.click

    view = wait_until { browser.div(:id, 'movies_gallery_view') }
    assert_match('/en/works/movies/#111', browser.url)

    frame = wait_until { browser.iframe(:index, 0) }
    editor = frame.div(:id, 'dijitEditorBody')
    assert_equal('UPDATED: Text of ArtObject 111', editor.text)

    logout
  end
end
