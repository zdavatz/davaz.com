require 'sbsm/logger'
SBSM.debug "start #{__FILE__}"
module DaVaz
  module TestCase

    def login_as(opts={})
      foot_container = wait_until { browser.div(id: 'foot_container') }
      login_link = foot_container.a(name: 'login')
      login_link.click

      form = browser.form(name: 'loginform')
      form.text_field(name: 'login_email').set(opts[:email])
      form.text_field(name: 'login_password').set(opts[:password])
      form.checkbox(name: 'remember_me').set
      form.button(name: 'login', type: 'submit').click
      sleep 0.5

      email_field = browser.text_field(:name => "login_email")
      if email_field.exist? && email_field.visible?
        assert false, 'Could not log in. Login-Field must no longer be present!'
      end
      login_link = browser.link(:text => 'Login')
      assert_equal(false, login_link.exists? && login_link.visible?, 'Could not log in. Login-link must no longer be present!')
    end

    def logout
      foot_container = wait_until { browser.div(id: 'foot_container') }
      logout_link = foot_container.a(name: 'logout')
      logout_link = browser.link(:name => 'logout')
      logout_link.click
      sleep 0.5
      assert_equal(nil, /fragment/.match(browser.url))
      email_field = browser.text_field(:name => "login_email")
      assert_equal(true,  browser.text_field(:name => "login_email").visible?, 'Login must be present!')
      login_link = browser.link(:text => 'Login')
      assert_equal(false, login_link.exists? && login_link.visible?, 'Could not log in. Login-link must no longer be present!')
    end
  end
end
