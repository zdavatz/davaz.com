#!/usr/bin/env ruby
$:.unshift File.expand_path('..', File.dirname(__FILE__))
require 'test_helper'

# /communication/shop
class TestShop < Minitest::Test
  include DaVaz::TestCase
  SLEEP_SECONDS = 0.5
  RUN_ALL_TESTS = true
  def setup
    browser.visit('/en/personal/work')
    sleep SLEEP_SECONDS
    link = browser.link(:name, 'shop')
    link.click
    sleep SLEEP_SECONDS
  end

  def remove_all_items
    browser.link(:text => /Remove all items/i).click if browser.link(:text => /Remove all items/i).exist?
    browser.text_fields.each{|t| t.clear}
  end

  def get_session_id
    cookie =  browser.cookies.to_a.find {|x| x[:name].eql?("_session_id")}
    cookie ? cookie[:value] : nil
  end

  def enter_value(id, value)
    item = browser.text_field(:id, id)
    item = browser.text_field(:name => id) unless item.exist?
    item.set(value.to_s)
    item.send_keys(:tab)
  end

  def assert_text_present(text_to_find)
    assert(browser.text.index(text_to_find), "browser text should match #{text_to_find} but is \n#{browser.text}")
  end

  def check_total(amount)
    total = /.*total.*/i.match(browser.text)
    assert(total, 'Should find line matching Total')
    assert(/CHF\s#{amount}\.-/.match(total[0]), "Should show correct total of #{amount} CHF, but is #{total[0]}")
  end

  def test_shopping_cart_calculation_with_publications
    assert_match('/en/communication/shop', browser.url)
    remove_all_items

    shopping_cart = Proc.new {
      wait_until { browser.table(:id, 'shopping_cart') }[0][0]
    }

    item = browser.text_field(:id, 'article[111]')
    item.set('2')
    item.send_keys(:tab)
    cart = shopping_cart.yield
    rows = wait_until { cart.table(:class, 'shopping-cart-list') }
    assert_equal('Title of ArtObject 111', rows[1][2].text)
    assert_equal('CHF 111.-', rows[1][4].text)
    assert(cart.text.include?('CHF 222.- / $ 176.- / € 132.'))

    item = browser.text_field(:id, 'article[112]')
    item.set('2')
    item.send_keys(:tab)
    cart = shopping_cart.yield
    rows = wait_until { cart.table(:class, 'shopping-cart-list') }
    assert_equal('Title of ArtObject 112', rows[1][2].text)
    assert_equal('CHF 112.-', rows[1][4].text)
    assert(cart.text.include?('CHF 446.- / $ 354.- / € 266.-'))

    item = browser.text_field(:id, 'article[113]')
    item.set('2')
    item.send_keys(:tab)
    cart = shopping_cart.yield
    assert(cart.text.include?('CHF 672.- / $ 534.- / € 400.-'))
    rows = wait_until { cart.table(:class, 'shopping-cart-list') }
    assert_equal('Title of ArtObject 113', rows[1][2].text)
    assert_equal('CHF 113.-', rows[1][4].text)

    rows = wait_until { cart.table(:class, 'shopping-cart-list') }
    assert_equal('Title of ArtObject 113', rows[1][2].text)
    assert_equal('Title of ArtObject 112', rows[2][2].text)
    assert_equal('Title of ArtObject 111', rows[3][2].text)

    link = browser.link(:text, 'Remove all items')
    link.click
  end if RUN_ALL_TESTS

  def test_checkout_fails_without_user_info
    assert_match('/en/communication/shop', browser.url)
    remove_all_items

    item = browser.text_field(:id, 'article[113]')
    item.set('2')
    item.send_keys(:tab)

    item = browser.text_field(:id, 'article[114]')
    item.set('1')
    item.send_keys(:tab)

    link = browser.button(:text, 'Order item(s)')
    link.click

    assert_text_present( 'Please fill out the fields that are marked with red.')

    link = browser.link(:text, 'Remove all items')
    link.click
  end if RUN_ALL_TESTS

  def test_checkout_fails_with_validation_error
    assert_match('/en/communication/shop', browser.url)
    remove_all_items

    item = browser.text_field(:id, 'article[113]')
    item.set('2')
    item.send_keys(:tab)

    item = browser.text_field(:id, 'article[114]')
    item.set('1')
    item.send_keys(:tab)

    browser.text_field(:name, 'name').set('John Smith')
    browser.text_field(:name, 'surname').set('Mr.')
    browser.text_field(:name, 'street').set('Winterthurerstrasse')
    browser.text_field(:name, 'postal_code').set('A')
    browser.text_field(:name, 'city').set('Zürich')
    browser.text_field(:name, 'country').set('Switzerland')
    browser.text_field(:name, 'email').set('john@example.org')
    link = browser.button(:text, 'Order item(s)')
    link.click

    assert_text_present('Your Postal Code seems to be invalid.')
    assert_text_present('Sorry, but your email-address seems to be invalid. Please try again.')

    link = browser.link(:text, 'Remove all items')
    link.click
  end if RUN_ALL_TESTS

  def test_test_shop2
    browser.visit "/en/communication/shop"
    remove_all_items
    112.upto(115).each do |id|
      link = browser.link(:text => "Title of ArtObject #{id}")
      link.click
      assert_text_present("Text of ArtObject #{id}")
      browser.back
    end
  end if RUN_ALL_TESTS

  def test_checkout_with_error
    session_id = get_session_id
    enter_value("article[113]", 2)
    check_total(2*113)
    enter_value("article[114]", 2)
    total = /.*total.*/i.match(browser.text)
    check_total(2*113 + 2*114)
    enter_value("article[113]", "4")
    enter_value("article[114]", "0")
    sleep SLEEP_SECONDS
    check_total(452)
    enter_value("name", "TestName")
    enter_value("surname", "TestSurname")
    enter_value("street", "TestStreet")
    enter_value("postal_code", "postal_code_must_be_integer")
    enter_value("city", "TestCity")
    enter_value("country", "TestCountry")
    enter_value("email", "TestEmail@test.org")
    browser.button(:name => 'order_item').click
    assert_text_present("Your Postal Code seems to be invalid.")
    assert_text_present("Sorry, but your email-address seems to be invalid. Please try again.")
    enter_value("postal_code", "8888")
    enter_value("email", "ngiger@ywesee.com")
    browser.click "order_item"
    assert_text_present("Your order has been succesfully sent.")
  end if RUN_ALL_TESTS

  def test_checkout
    remove_all_items
    session_id = get_session_id
    SBSM.info "There should be no cart_items @session session_id is #{get_session_id}"
    enter_value("article[113]", 2)
    sleep SLEEP_SECONDS
    session_id2 = get_session_id
    SBSM.info "The GET should have resulted one cart_item @session session_id is  #{session_id} #{session_id2}"
    assert_equal(session_id, session_id2, 'Session-IDs should match')
    check_total(2*113)
    enter_value("article[114]", 2)
    total = /.*total.*/i.match(browser.text)
    sleep SLEEP_SECONDS
    SBSM.info "The GET should have resulted in two cart_items session_id is  #{get_session_id}"
    enter_value("name", "TestName")
    enter_value("surname", "TestSurname")
    enter_value("street", "TestStreet")
    enter_value("postal_code", "8888")
    enter_value("city", "TestCity")
    enter_value("country", "TestCountry")
    enter_value("email", "TestEmail@test.org")
    Mail::TestMailer.deliveries.clear
    assert_equal(0, Mail::TestMailer.deliveries.length, 'No mails delivered yet')
    browser.button(:name => 'order_item').click
    assert_text_present("Your order has been succesfully sent.")
    # cannot test here, as it is sent in a different process!
    # assert_equal(1, Mail::TestMailer.deliveries.length, 'Must have deliverd an e-mail')
  end
end