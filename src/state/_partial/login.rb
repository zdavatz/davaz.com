require 'state/predefine'
require 'view/_partial/ajax'
require 'view/_partial/login'

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
        @session.active_state.extend(Admin)
      end
      LoginStatus.new(@session, 'success' => true)
    end
  end

  class LoginStatus < SBSM::State
    VIEW     = DaVaz::View::Ajax
    VOLATILE = true
  end

  class LoginForm < SBSM::State
    VIEW     = DaVaz::View::LoginForm
    VOLATILE = true

    def init
      @model = OpenStruct.new
      @model.fragment = @session.user_input(:fragment)
    end
  end
end
