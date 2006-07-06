#!/usr/bin/env ruby
# State::Admin::LoginForm -- davaz.com -- 08.06.2006 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'state/admin/admin'
require 'view/admin/login_form'

module DAVAZ
	module State
		module Admin
class LoginForm < State::Admin::Global
	VIEW = View::Admin::LoginForm
	def login
		@session.login
		if(@session.user.allowed?('edit', 'com.davaz'))
			self.extend(State::Admin::Admin)
		end
		State::Admin::AdminHome.new(@session, @model)
	#rescue Yus::YusError
	end
end
		end
	end
end
