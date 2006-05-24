#!/usr/bin/env ruby
# View::Communication::Links -- davaz.com -- 12.09.2005 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/textblock'
require 'htmlgrid/divcomposite'
require 'htmlgrid/divlist'
require 'htmlgrid/link'

module DAVAZ
	module View
		module Communication
=begin
class LinksList < View::List
	OMIT_HEADER = true
	DEFAULT_CLASS = HtmlGrid::Value
	OFFSET_STEP = [0,2]
	#CSS_CLASS = 'content'
	COMPONENTS = {
		[0,0]	=>	:url,
		[1,0]	=>	:date,
		[0,1]	=>	:text,
	}
	CSS_MAP = {
		[0,0]	=>	'title',
		[1,0]	=>	'date',
		[0,1]	=>	'text',
	}
	def url(model)
		link = HtmlGrid::HttpLink.new(:url, model, @session, self) 
		link.href = "http://" + model.url
		link.value = model.url
		link.target = '_blank'
		link.css_class = 'link-url'
		link
	end
	def date(model)
		model.date.strftime("%d.%m.%Y")
	end
end
=end
class LinksList < HtmlGrid::DivList
	CSS_CLASS = 'links'
	COMPONENTS = {
		[0,0]	=>	View::LinkTextBlock,
	}	
end
class LinksTitle < HtmlGrid::Div
	CSS_CLASS = 'table-title'
	def init
		super
		span = HtmlGrid::Span.new(:links_from_davaz, model, @session)
		span.value = @lookandfeel.lookup(:links_from_davaz)
		span.css_class = 'table-title'
		@value = span
	end
end
class LinksComposite < HtmlGrid::DivComposite
	CSS_CLASS = 'content'
	COMPONENTS = {
		[0,0]	=>	LinksTitle,
		[1,0]	=>	LinksList,
	}
end
class Links < View::CommunicationPublicTemplate
	CONTENT = View::Communication::LinksComposite
end
		end
	end
end
