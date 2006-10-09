#!/usr/bin/env ruby
# View::Admin::LoginForm -- davaz.com -- 08.06.2006 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/form'
require 'htmlgrid/divcomposite'
require 'htmlgrid/pass'
require 'htmlgrid/errormessage'

module DAVAZ
	module View
		module Admin
class LoginForm < View::Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]   =>  :email,
		[0,1]   =>  :pass,
		[1,2,1]	=>  :submit,
		[1,2,2]	=>  :cancel,
	}
	CSS_MAP = {
		[0,0,2,3]	=>	'list',
	}
	CSS_CLASS = 'component'
	EVENT = :login
	LABELS = true
	FORM_NAME = 'loginform'
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
	def init
		super
		error_message()
		self.onsubmit = 'return false;'
	end
	def cancel(model)
		button = HtmlGrid::Button.new(:cancel, model, @session, self)
		button.css_id = 'login-form-cancel-button'
		button
	end
	def hidden_fields(context)
		super <<
		context.hidden('fragment', "#{@model.fragment}")
	end
end
		end
	end
end
