module DaVaz
  module TestCase

    def login_as(opts={})
      foot_container = wait_until { browser.div(id: 'foot_container') }
      login_link = foot_container.a(name: 'login')
      login_link.click

      form = wait_until { browser.form(name: 'loginform') }
      form.text_field(name: 'login_email').set(opts[:email])
      form.text_field(name: 'login_password').set(opts[:password])
      form.checkbox(name: 'remember_me').set
      form.button(name: 'login', type: 'submit').click
    end

    def logout
      foot_container = wait_until { browser.div(id: 'foot_container') }
      logout_link = foot_container.a(name: 'logout')
      logout_link.click
    end
  end
end
