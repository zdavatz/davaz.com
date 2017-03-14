#!/usr/bin/env ruby
$:.unshift File.expand_path('..', File.dirname(__FILE__))
require 'test_helper'

# /works/drawings
class TestDrawings < Minitest::Test
  include DaVaz::TestCase
  RUN_ALL_TESTS = false
  def setup
    startup_server
    browser.visit('/en/personal/work')
    link = browser.link(:id, 'drawings')
    link.click
  end

  OTHER_ART_OBJECTS = /There are other artobjects assigned to this element.+Please assign them to another element first./
  def teardown
    logout
    shutdown_server
  end

  def test_drawings_view
    assert_match('/en/works/drawings', browser.url)

    title = 'Title of ArtObject 111'
    visit_desk(title)
    artobject_title = wait_until { browser.div(:id, 'artobject_title') }
    assert_equal(title, artobject_title.text)
  end if RUN_ALL_TESTS

  def test_admin_drawings_canceling_of_add_new_serie
    assert_match('/en/works/drawings', browser.url)

    login_as(email: TEST_USER, password: TEST_PASSWORD)

    title = 'Title of ArtObject 112'
    visit_desk(title)
    artobject_title = wait_until { browser.div(id: 'artobject_title') }

    form_table = browser.table(id: 'artobject_details')
    selected = form_table.select_list(name: 'serie_id')
    assert_equal('ABC', selected.value)

    # add
    add_link = form_table.a(name: 'add_serie')
    add_link.click
    input = wait_until { form_table.text_field(name: 'serie_add_form_input') }
    assert_empty(input.text)

    # cancel by re:click
    add_link.click
    input = form_table.text_field(name: 'serie_add_form_input')
    refute(input.exists?)

    # add
    add_link.click
    input = wait_until { form_table.text_field(name: 'serie_add_form_input') }
    assert_empty(input.text)

    # cancel
    cancel_link = form_table.a(name: 'cancel')
    cancel_link.click
    input = form_table.text_field(name: 'serie_add_form_input')
    refute(input.exists?)
  end

  def test_admin_drawings_removing_serie_failure
    assert_match('/en/works/drawings', browser.url)

    login_as(email: TEST_USER, password: TEST_PASSWORD)

    title = 'Title of ArtObject 112'
    visit_desk(title)
    artobject_title = wait_until { browser.div(id: 'artobject_title') }

    form_table = browser.table(id: 'artobject_details')
    selected = form_table.select_list(name: 'serie_id')
    assert_equal('ABC', selected.value)

    remove_link = form_table.a(name: 'remove_serie')
    remove_link.click
    container = wait_until { form_table.td(id: 'serie_id_container') }
    sleep(1) unless OTHER_ART_OBJECTS.match(container.text)
    assert_match(OTHER_ART_OBJECTS, container.text)

    # it has still same value
    selected = form_table.select_list(name: 'serie_id')
    assert_equal('ABC', selected.value)
  end if RUN_ALL_TESTS

  def test_admin_drawings_removing_serie_success
    assert_match('/en/works/drawings', browser.url)

    login_as(email: TEST_USER, password: TEST_PASSWORD)

    title = 'Title of ArtObject 112'
    visit_desk(title)
    artobject_title = wait_until { browser.div(id: 'artobject_title') }

    form_table = browser.table(id: 'artobject_details')
    selected = form_table.select_list(name: 'serie_id')
    assert_equal('ABC', selected.value)

    # add
    add_link = form_table.a(name: 'add_serie')
    add_link.click
    input = wait_until { form_table.text_field(name: 'serie_add_form_input') }
    input.set('Name of Serie ABF')
    submit_link = form_table.a(name: 'submit')
    submit_link.click

    selected = wait_until { form_table.select_list(name: 'serie_id') }
    sleep 1 unless 'ABF'.eql?(selected.value)
    assert_equal('ABF', selected.value)

    remove_link = form_table.a(name: 'remove_serie')
    remove_link.click
    container = wait_until { form_table.td(id: 'serie_id_container') }
    sleep(1) if OTHER_ART_OBJECTS.match(container.text)
    refute_match(OTHER_ART_OBJECTS, container.text)
    remove_link = form_table.a(name: 'remove_serie')
    assert_equal('color: grey;', remove_link.style)

    # back to previous value
    selected = form_table.select_list(name: 'serie_id')
    assert_equal('ABC', selected.value)
  end if RUN_ALL_TESTS

  private

  def visit_desk(title)
    link = wait_until { browser.link(name: 'desk') }
    link.click
    result_list = wait_until { browser.div(id: 'rack_result_list_composite') }
    title_link = wait_until { result_list.a(text: title) }
    title_link.click
  end
end
