require 'test_helper'
require 'sbsm/logger'
SBSM.debug "start #{__FILE__}"
module DaVaz
  module TestCase

    def login_as(opts={}, a_browser = browser)
      foot_container = wait_until { a_browser.div(id: 'foot_container') }
      logout_link = a_browser.link(name: 'logout')
      logout_link.click if logout_link.exist?
      login_link = a_browser.link(text: 'Login')
      login_link.wait_until(&:exist?)
      login_link.click

      form = a_browser.form(name: 'loginform')
      form.wait_until(& :present?)
      form.text_field(name: 'login_email').wait_until(&:visible?)
      form.text_field(name: 'login_email').set(opts[:email])
      form.text_field(name: 'login_password').set(opts[:password])
      form.checkbox(name: 'remember_me').set
      form.button(name: 'login', type: 'submit').click
      sleep 0.5

      email_field = a_browser.text_field(name: "login_email")
      if email_field.exist? && email_field.visible?
        assert false, 'Could not log in. login_email-Field must no longer be present!'
      end
      login_link = a_browser.link(text: 'Login')
      # require 'pry'; binding.pry if login_link.exists? && login_link.visible?
      # after calling a_browser.goto(a_browser.links.find{|x| x.text.eql?('Guestbook')}.href)
      # the login_link removes
      puts 'Did not check absence of login link'
      # assert_equal(false, login_link.exists? && login_link.visible?, 'Could not log in. Login-link must no longer be present!')
    end

    def logout(a_browser = browser)
      logout_link = a_browser.link(name: 'logout')
      return unless logout_link.exist?
      logout_link.click
      assert_nil /fragment/.match(a_browser.url)
      email_field = a_browser.text_field(name: "login_email")
      assert_equal(false,  a_browser.text_field(name: "login_email").exist?, 'login_email must no longer be present!')
      login_link = a_browser.link(text: 'Login')
      login_link.wait_until(&:exist?)
      assert_equal(false, logout_link.exists? && logout_link.visible?, 'Could not log in. Logout-link must no longer be present!')
    end
  end
end
