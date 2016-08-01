require 'state/_partial/redirect'
require 'state/_partial/admin_methods'
require 'state/_partial/login_form'

module DaVaz::State
  module LoginMethods
    def login
      autologin(@session.login)
    rescue Yus::YusError
      model = {
        'success' => false,
        'message' => @session.lookandfeel.lookup(:e_incorrect_login),
      }
      LoginStatus.new(@session, model)
    end

    private

    def autologin(user)
      if user.valid? && user.allowed?('edit', 'com.davaz')
        @session.active_state.extend(AdminMethods)
      end
      LoginStatus.new(@session, 'success' => true)
    end
  end
end
