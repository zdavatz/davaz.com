require 'sbsm/state'
require 'state/predefine'
require 'view/_partial/ajax'
require 'view/_partial/login_form'

module DaVaz::State
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
