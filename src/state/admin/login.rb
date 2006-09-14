#!/usr/bin/env ruby
# State::Admin::Login -- davaz.com -- 04.09.2006 -- mhuggler@ywesee.com

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
			'success' =>	false,
			'message'	=>	@session.lookandfeel.lookup(:e_incorrect_login),
		}
		AjaxLoginStatus.new(@session, model)
=begin
  rescue Yus::UnknownEntityError
    @errors.store(:email, create_error(:e_authentication_error, :email, nil))
		newstate
  rescue Yus::AuthenticationError
    @errors.store(:pass, create_error(:e_authentication_error, :pass, nil))
		newstate
=end
	end
	private
	def autologin(user)
		#no need anymore because auf ajax login
		#model = @previous.request_path
=begin
		model = self.request_path
		if(fragment = @session.user_input(:fragment))
			model << "##{fragment}" unless fragment.empty?
		end
		newstate = State::Redirect.new(@session, model)
=end
		if(user.valid? && user.allowed?('edit', 'com.davaz'))
			@session.active_state.extend(State::Admin::Admin)
		end
		AjaxLoginStatus.new(@session, { 'success' => true })
	end
end
class AjaxLoginStatus < SBSM::State
	VIEW = View::AjaxResponse 
	VOLATILE = true
end
class AjaxLoginForm < SBSM::State
	VIEW = View::Admin::LoginForm
	VOLATILE = true
	def init
		@model = OpenStruct.new
		@model.fragment = @session.user_input(:fragment)
	end
end
class Login < State::Admin::Global
	DIRECT_EVENT = :login_form
	VIEW = View::Admin::LoginForm
	def init
		@model = OpenStruct.new
		@model.fragment = @session.user_input(:fragment)
	end
end
		end
	end
end
