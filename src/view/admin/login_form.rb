#!/usr/bin/env ruby
# View::Admin::LoginForm -- davaz.com -- 08.06.2006 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/form'
require 'htmlgrid/divcomposite'
require 'htmlgrid/pass'

module DAVAZ
	module View
		module Admin
class LoginFormForm < View::Form
	COMPONENTS = {
		[0,0]   =>  :email,
		[0,1]   =>  :pass,
		[1,2]   =>  :submit,
	}
	CSS_MAP = {
		[0,0,2,3]	=>	'list',
	}
	CSS_CLASS = 'component'
	EVENT = :login
	LABELS = true
	SYMBOL_MAP = {
		:pass	=>	HtmlGrid::Pass,
	}
=begin
	def email(model)
		input = HtmlGrid::InputText.new(:username, model, @session, self)
		input.css_id = 'username'
		self.onload = "document.getElementById('username').focus();"
		input
	end
=end
end
class LoginFormComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	View::Admin::LoginFormForm,
	}
	CSS_ID_MAP = {
		0	=>	'login-form'
	}
end
class LoginForm < View::PublicTemplate
	CONTENT = View::Admin::LoginFormComposite
end
		end
	end
end
