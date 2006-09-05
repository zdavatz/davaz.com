#!/usr/bin/env ruby
# State::Admin::Login -- davaz.com -- 04.09.2006 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'state/admin/admin'
require 'state/redirect'
require 'view/admin/login_form'

module DAVAZ
	module State
		module Admin
module LoginMethods
	def login
		autologin(@session.login)
  rescue Yus::UnknownEntityError
    @errors.store(:email, create_error(:e_authentication_error, :email, nil))
    self
  rescue Yus::AuthenticationError
    @errors.store(:pass, create_error(:e_authentication_error, :pass, nil))
    self
	end
	private
	def autologin(user)
		model = @previous.request_path
		if(fragment = @session.user_input(:fragment))
			model << "##{fragment}" unless fragment.empty?
		end
		newstate = State::Redirect.new(@session, model)
		if(user.valid? && user.allowed?('edit', 'com.davaz'))
			newstate.extend(State::Admin::Admin)
		end
		newstate
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
