#!/usr/bin/env ruby
# View::Personal::Inspiration -- davaz.com -- 27.09.2005 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/works/oneliner'
require 'view/personal/life'
require 'htmlgrid/divcomposite'
require 'htmlgrid/span'

module DAVAZ
	module View
		module Personal
class InspirationTitle < HtmlGrid::Div
	CSS_CLASS = 'table-title center'
	def init
		super
		img = HtmlGrid::Image.new(:inspiration_title, model, @session, self)
		@value = img 
	end
end
class InspirationText < HtmlGrid::DivList
	CSS_CLASS = 'intro-text'
	COMPONENTS = {
		[0,0]	=>	View::TextBlock,
	}
end
class InspirationComposite < HtmlGrid::DivComposite
	CSS_ID = 'inner-content'
	COMPONENTS = {
		[0,0]	=>	InspirationTitle,
		[1,0]	=>	component(View::Works::OneLiner, :oneliner),
		[2,0]	=>	component(InspirationText, :text),	
		[3,0]	=>	:india_ticker_link,
	}
	def india_ticker_link(model)
		link = HtmlGrid::Link.new(:india_ticker_link, model, @session, self)
		link.href = "javascript:void(0)"
		link.attributes['onclick']	= 'toggleTicker();' 
		link.value = @lookandfeel.lookup(:india_ticker_link)
		div = HtmlGrid::Div.new(model, @session, self)
		div.css_id = 'ticker-link'
		div.value = link
		div	
	end
end
class Inspiration < View::PersonalPublicTemplate
	CONTENT = View::Personal::InspirationComposite
	TICKER = 'A passage through India'
end
		end
	end
end
