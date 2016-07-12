require 'state/global_predefine'
require 'state/admin/admin'
require 'state/redirect'
require 'view/admin/login_form'
require 'view/ajax_response'

module DAVAZ
  module State
    module Admin
      module LoginMethods
        def login
          autologin(@session.login)
        rescue Yus::YusError
          model = {
            'success' => false,
            'message' => @session.lookandfeel.lookup(:e_incorrect_login),
          }
          AjaxLoginStatus.new(@session, model)
        end

        private

        def autologin(user)
          if user.valid? && user.allowed?('edit', 'com.davaz')
            @session.active_state.extend(State::Admin::Admin)
          end
          AjaxLoginStatus.new(@session, 'success' => true)
        end
      end

      class AjaxLoginStatus < SBSM::State
        VIEW     = View::AjaxResponse
        VOLATILE = true
      end

      class AjaxLoginForm < SBSM::State
        VIEW     = View::Admin::LoginForm
        VOLATILE = true

        def init
          @model = OpenStruct.new
          @model.fragment = @session.user_input(:fragment)
        end
      end
    end
  end
end
