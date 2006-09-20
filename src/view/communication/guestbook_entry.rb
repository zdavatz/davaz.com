#!/usr/bin/env ruby
# View::Communication::GuestbookForm -- davaz.com -- 14.09.2005 -- mhuggler@ywesee.com

require 'view/form'
require 'view/publictemplate'
require 'htmlgrid/errormessage'
require 'htmlgrid/textarea'

module DAVAZ
	module View
		module Communication
class GuestbookEntryTitle < HtmlGrid::Div
	CSS_CLASS = 'table-title'
	def init
		super
		span = HtmlGrid::Span.new(model, @session, self)
		span.css_class = 'table-title'
		span.value = @lookandfeel.lookup(:new_guestbook_entry)
		@value = span
	end
end
class GuestbookEntryForm < View::Form
	include HtmlGrid::ErrorMessage
	LABELS = true
	EVENT = :submit_entry
	CSS_CLASS = 'guestbookentry-form'
	COMPONENTS = {
		[0,0]	=>	:name,
		[2,0]	=>	:surname,
		[0,1]	=>	:email,
		[0,2]	=>	:city,
		[2,2]	=>	:country,
		[0,3]	=>	:messagetxt,
		[1,4]	=>	:submit,
		[1,4,1]	=>	:cancel,
	}
	COLSPAN_MAP = {
		[1,3]	=>	3,
		[1,4]	=>	3,
	}
	CSS_MAP = {
		[0,0,1,4]	=>	'labels',	
		[2,0,1,3]	=>	'labels',	
		[0,4]	=>	'add-entry',
	}
	SYMBOL_MAP = {
		:name			=>	HtmlGrid::InputText,
		:surname	=>	HtmlGrid::InputText,	
		:city			=>	HtmlGrid::InputText,	
		:country	=>	HtmlGrid::InputText,	
	}
	def init
		super
		error_message
		self.onsubmit = 'return false;'
	end
	def messagetxt(model)
		input = HtmlGrid::Textarea.new(:messagetxt, model, @session, self)
		input.set_attribute('rows', 10)
		input.set_attribute('wrap', true)
		input.css_id = 'guestbook-message'
		input.label = true
		input
	end
	def submit(model)
		button = HtmlGrid::Button.new(:submit_entry, model, @session, self)
		button.value = @lookandfeel.lookup(:submit_entry)
		button.css_class = 'add-entry' 
		button.attributes['type'] = 'submit'
		button
	end
	def cancel(model)
		button = HtmlGrid::Button.new(:cancel, model, @session, self)
		button.value = @lookandfeel.lookup(:cancel)
		button.css_class = 'add-entry' 
		button.css_id = 'cancel-add-entry'
		button
	end
end
		end
	end
end
