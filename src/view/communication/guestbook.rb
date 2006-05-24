#!/usr/bin/env ruby
# View::Commmunication::Guestbook -- davaz.com -- 12.09.2005 -- mhuggler@ywesee.com

require 'view/list'
require 'view/publictemplate'
require 'htmlgrid/divcomposite'
require 'htmlgrid/divlist'
require 'htmlgrid/button'
require 'date'

module DAVAZ
	module View
		module Communication 
class Guest < View::Composite
	CSS_CLASS = 'guestbook-entry'
	LABELS = true
	DEFAULT_CLASS = HtmlGrid::Value
	OFFSET_STEP = [0,4]
	COMPONENTS = {
		[0,0]	=>	'name',
		[1,0]	=>	:name,
		[2,0]	=>	:date,
		[0,1]	=>	:city,
		[0,2]	=>	:country,
		[0,3]	=>	:text,
	}
	COLSPAN_MAP = {
		[1,1]	=> 2,
		[1,2]	=> 2,
		[1,3]	=> 2,
	}
	CSS_MAP = {
		[2,0]				=>	'date-right',
		[0,0,1,4]		=>	'label',
		[1,0,1]			=>	'guestbook-entry-text',
		[1,1,2,3]		=>	'guestbook-entry-text',
	}
	def name(model)
		[model.firstname, model.lastname].join(" ")
	end
	def date(model)
		Date.parse(model.date).strftime("%d.%m.%Y")	
	end
end
class GuestList < HtmlGrid::DivList
	COMPONENTS = {
		[0,0]	=>	Guest,
	}
	CSS_MAP = {
		0	=>	'guestbook',
	}
end
class GuestbookTitle < HtmlGrid::Div
	CSS_CLASS = 'table-title'
	def init
		super
		span = HtmlGrid::Span.new(model, @session, self)
		span.css_class = 'table-title'
		span.value = @lookandfeel.lookup(:davaz_guestbook)
		@value = span
	end
end
class GuestbookInfo < HtmlGrid::Div
	CSS_CLASS = 'table-info'
	def init
		super
		span = HtmlGrid::Span.new(model, @session, self)
		span.css_class = 'table-info'
		span.value = @lookandfeel.lookup(:guestbook_info)
		@value = span
	end
end
class GuestbookButton < HtmlGrid::Div
	CSS_CLASS = 'guestbook-button'
	def init
		super
		button = HtmlGrid::Button.new(:new_entry, model, @session, self)
		button.value = @lookandfeel.lookup(:new_entry)
		button.css_class = 'new-entry' 
		link = HtmlGrid::Link.new(:new_guestbook_entry, model, @session, self)
		link.href = @lookandfeel.event_url(:communication, :guestbookentry)
		link.value = button
		@value = link 
	end
end
class GuestbookComposite < HtmlGrid::DivComposite
	CSS_CLASS = 'content'
	COMPONENTS = {
		[0,0]	=>	GuestbookTitle, 
		[1,0]	=>	GuestbookInfo, 
		[2,0]	=>	GuestbookButton,
		[3,0]	=>	GuestList, 
	}
end
class Guestbook < View::CommunicationPublicTemplate
	CONTENT = View::Communication::GuestbookComposite
end
		end
	end
end
