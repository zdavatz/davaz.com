require 'test_helper'

class TestShop < Minitest::Test
  include DAVAZ::TestCase

  def test_shopping_publications
    browser.visit('/en/gallery/gallery')
    link = browser.link(:name, 'shop')
    assert_match('/en/communication/shop', link.href)
    link.click
    browser.wait(3)
    cart = browser.table(:id, 'shopping_cart')[0][0]
    item = browser.text_field(:id, 'article[111]')
    item.set('2')
    item.send_keys(:tab)
    list = cart.table(:class, 'shopping-cart-list')[1][2]
    assert_equal('Title of ArtObject 111', list.text)

    #browser.text_field(:id, 'article[1046]').set('2')
    #browser.wait(1)
    #list = cart.table(:class, 'shopping-cart-list')[2][2]
    #assert_equal('Wunderblock', list.text)

    #browser.text_field(:id, 'article[1295]').set('2')
    #browser.wait(1)
    #list = cart.table(:class, 'shopping-cart-list')[3][2]
    #assert_equal('Psychospheres', list.text)

    #browser.text_field(:id, 'article[1292]').set('2')
    #browser.wait(1)
    #list = cart.table(:class, 'shopping-cart-list')[4][2]
    #assert_equal('Drawings', list.text)

    #browser.element(:xpath, )
    #browser.is_text_present('CHF 222.-')
    #assert browser.is_text_present('CHF 224.-')
    #assert browser.is_text_present('CHF 226.-')
    #assert browser.is_text_present('CHF 672.- / $ 534.- / € 400.-')
    #browser.click 'link=remove all items'
    #sleep 3

    #refute browser.is_text_present('CHF 222.-')
    #refute browser.is_text_present('CHF 224.-')
    #refute browser.is_text_present('CHF 226.-')
    #refute browser.is_text_present('CHF 672.- / $ 534.- / € 400.-')
    # @browser.type "article[113]", "2"
    # @browser.type "article[114]", "2"
    # sleep 3
    # assert @browser.is_text_present("CHF 226.-")
    # @browser.type "article[113]", "4"
    # @browser.type "article[114]", "0"
		# sleep 3
    # assert @browser.is_text_present("CHF 452.-")
    # assert @browser.is_text_present("CHF 452.- / $ 360.- / € 268.-")
    # @browser.click "order_item"
    # @browser.wait_for_page_to_load "30000"
    # assert @browser.is_text_present("Please fill out the fields that are marked with red.")
    # @browser.type "name", "TestName"
    # @browser.type "surname", "TestSurname"
    # @browser.type "street", "TestStreet"
    # @browser.type "postal_code", "TestZip"
    # @browser.type "city", "TestCity"
    # @browser.type "country", "TestCountry"
    # @browser.type "email", "TestEmail"
    # @browser.click "order_item"
    # @browser.wait_for_page_to_load "30000"
    # assert @browser.is_text_present("Your Postal Code seems to be invalid.")
    # assert @browser.is_text_present("Sorry, but your email-address seems to be invalid. Please try again.")
    # @browser.type "postal_code", "8888"
    # @browser.type "email", "mhuggler@ywesee.com"
    # @browser.click "order_item"
    # @browser.wait_for_page_to_load "30000"
    # assert @browser.is_text_present("Your order has been succesfully sent.")
	end

	#def test_test_shop2
  #  @browser.open "/en/communication/shop"
  #  @browser.wait_for_page_to_load "30000"
  #  @browser.click "link=Title of ArtObject 112"
  #  @browser.wait_for_page_to_load "30000"
  #  assert @browser.is_text_present("Text of ArtObject 112")
  #  @browser.click "paging_next"
  #  @browser.wait_for_page_to_load "30000"
  #  assert @browser.is_text_present("Text of ArtObject 113")
  #  @browser.click "link=Back To Shop"
  #  @browser.wait_for_page_to_load "30000"
  #  assert @browser.is_text_present("Title of ArtObject 114")
  #end
end
