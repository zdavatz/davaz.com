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
	EVENT = :add_entry
	CSS_CLASS = 'guestbookentry-form'
	COMPONENTS = {
		[0,0]	=>	:name,
		[2,0]	=>	:surname,
		[0,1]	=>	:email,
		[0,2]	=>	:city,
		[2,2]	=>	:country,
		[0,3]	=>	:messagetxt,
		[1,4]	=>	:submit,
	}
	CSS_MAP = {
		[1,4]	=>	'add-entry',
	}
	SYMBOL_MAP = {
		:name			=>	HtmlGrid::InputText,
		:surname	=>	HtmlGrid::InputText,	
		:email		=>	HtmlGrid::InputText,	
		:city			=>	HtmlGrid::InputText,	
		:country	=>	HtmlGrid::InputText,	
	}
	COLSPAN_MAP = {
		[1,3]	=>	4,
		[1,4]	=>	3,
	}
	def init
		super
		error_message
	end
	def messagetxt(model)
		input = HtmlGrid::Textarea.new(:messagetxt, model, @session, self)
		input.set_attribute('cols', 70)
		input.set_attribute('rows', 10)
		input.set_attribute('wrap', true)
		#js = "if(this.value.length > 400) { (this.value = this.value.substr(0,400))}" 
		#input.set_attribute('onKeypress', js)
		input.label = true
		input
	end
	def submit(model)
		button = HtmlGrid::Button.new(:add_entry, model, @session, self)
		button.value = @lookandfeel.lookup(:add_entry)
		button.css_class = 'add-entry' 
		button.attributes['type'] = 'submit'
		button
	end
end
class GuestbookEntryComposite < HtmlGrid::DivComposite
	CSS_CLASS = 'content'
	COMPONENTS = {
		[0,0]	=>	GuestbookEntryTitle,
		[1,0]	=>	GuestbookEntryForm,
	}
end
class GuestbookEntry < View::CommunicationPublicTemplate
	CONTENT = View::Communication::GuestbookEntryComposite
end
		end
	end
end
