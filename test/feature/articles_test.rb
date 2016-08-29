require 'test_helper'

# /public/articles
class TestArticles < Minitest::Test
  include DaVaz::TestCase

  def setup
    browser.visit('/en/public/articles')
  end

  def test_article_has_toggle_article_links
    assert_match('/en/public/articles', browser.url)

    link = wait_until { browser.a(name: 'toggle-article') }
    assert_equal('Title of ArtObject 111', link.text)
    link.click

    text = wait_until { browser.div(class: 'article-text') }
    close_link = text.a(name: 'toggle-article', class: 'close-link')
    assert_equal('Close article', close_link.text)
    assert(close_link.exists?)
  end
end
