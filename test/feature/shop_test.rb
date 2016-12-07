#!/usr/bin/env ruby
$:.unshift File.expand_path('..', File.dirname(__FILE__))
require 'test_helper'

# /communication/shop
class TestShop < Minitest::Test
  include DaVaz::TestCase
  SLEEP_SECONDS = 0.5

  def setup
    startup_server
    browser.visit('/en/personal/work')
    sleep SLEEP_SECONDS
    link = browser.link(:name, 'shop')
    link.click
    sleep SLEEP_SECONDS
  end

  def teardown
    logout
    shutdown_server
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

  def check_total(amount)
    sleep SLEEP_SECONDS
    total = /.*total.*/i.match(browser.text)
    assert(total, 'Should find line matching Total')
    regexp = /CHF\s#{amount}\.-/
    unless regexp.match(total[0])
      puts "Caller #{caller[0]}"
    end
    assert(regexp.match(total[0]), "Should show correct total of #{amount} CHF, but is #{total[0]}")
  end

  def wait_and_check_cart(expected, row, column)
    cart =  wait_until { browser.table(:id, 'shopping_cart') }[0][0]
    wait_until { cart.table(:class, 'shopping-cart-list') }
    0.upto(10).each do |x|
      break if expected.eql?(cart.table(:class, 'shopping-cart-list')[row][column].text)
      sleep 0.1
    end
    # binding.pry unless expected.eql?(cart.table(:class, 'shopping-cart-list')[row][column].text)
    assert_equal( expected, cart.table(:class, 'shopping-cart-list')[row][column].text)
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
    wait_and_check_cart('Title of ArtObject 111', 1,2)
    rows = wait_until { cart.table(:class, 'shopping-cart-list') }
    assert_equal('Title of ArtObject 111', rows[1][2].text)
    cart = shopping_cart.yield
    wait_and_check_cart('Title of ArtObject 111', 1,2)
    wait_and_check_cart('CHF 111.-', 1,4)
    assert(cart.text.include?('CHF 222.- / $ 176.- / € 132.'))

    item = browser.text_field(:id, 'article[112]')
    item.set('2')
    item.send_keys(:tab)
    cart = shopping_cart.yield
    wait_and_check_cart('Title of ArtObject 112', 1,2)
    wait_and_check_cart('CHF 112.-', 1,4)

    item = browser.text_field(:id, 'article[113]')
    item.set('2')
    item.send_keys(:tab)
    cart = shopping_cart.yield
    wait_and_check_cart('Title of ArtObject 113', 1,2)
    wait_and_check_cart('CHF 113.-', 1,4)
    wait_and_check_cart('Title of ArtObject 112', 2,2)
    wait_and_check_cart('Title of ArtObject 111', 3,2)
    link = browser.link(:text, 'Remove all items')
    link.click
    assert_nil(/ArtObject/.match cart.text)
  end
if true
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
  end

  def test_checkout_fails_with_validation_error
    assert_match('/en/communication/shop', browser.url)
    remove_all_items
    browser.text_field(:name, 'postal_code').set('A')
    browser.text_field(:name, 'email').set('wrong_email_addr')
    link = browser.button(:text, 'Order item(s)')
    link.click

    assert_text_present( 'Please fill out the fields that are marked with red.')
    skip('TODO: The postal code is marked as red, but the error message is not shown')
    assert_text_present('Your Postal Code seems to be invalid.')
    assert_text_present('Sorry, but your email-address seems to be invalid. Please try again.')

    link = browser.link(:text, 'Remove all items')
    link.click
  end

  def test_test_shop2
    browser.visit "/en/communication/shop"
    remove_all_items
    112.upto(115).each do |id|
      link = browser.link(:text => "Title of ArtObject #{id}")
      link.click
      assert_text_present("Text of ArtObject #{id}")
      browser.back
    end
  end

  def test_checkout_with_error
    session_id = get_session_id
    enter_value("article[113]", 2)
    check_total(2*113)
    enter_value("article[114]", 3)
    total = /.*total.*/i.match(browser.text)
    check_total(2*113 + 3*114)
    enter_value("article[113]", "4")
    enter_value("article[114]", "0")
    check_total(4*113)
    enter_value("name", "TestName")
    enter_value("surname", "TestSurname")
    enter_value("street", "TestStreet")
    enter_value("postal_code", "postal_code_must_be_integer")
    enter_value("city", "TestCity")
    enter_value("country", "TestCountry")
    enter_value("email", "TestEmail@test.org")
    browser.button(:name => 'order_item').click
    skip('TODO: The postal code is marked as red, but the error message is not shown')
    assert_text_present( 'Please fill out the fields that are marked with red.')
    assert_text_present("Your Postal Code seems to be invalid.")
    assert_text_present("Sorry, but your email-address seems to be invalid. Please try again.")
    enter_value("postal_code", "8888")
    enter_value("email", "ngiger@ywesee.com")
    browser.click "order_item"
    assert_text_present("Your order has been succesfully sent.")
  end

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
end