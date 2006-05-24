#!/usr/bin/env ruby
# View::Personal::Work -- davaz.com -- 27.09.2005 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/textblock'
require 'view/works/oneliner'
require 'htmlgrid/divcomposite'
require 'htmlgrid/image'

module DAVAZ
	module View
		module Personal
class MorphopolisTickerLink < HtmlGrid::Div
	CSS_ID = 'ticker-link'
	def init
		super
		link = HtmlGrid::Link.new(:morphopolis_ticker_link, model, @session, self)
		link.href = "javascript:void(0)"
		link.attributes['onclick']	=  'toggleTicker();'
		link.value = @lookandfeel.lookup(:morphopolis_ticker_link)
		@value = link
	end
end
class MorphopolisTicker < HtmlGrid::Div
	CSS_ID = 'ticker'
	def init
		super
		model = @session.app.load_slideshow('morphopolis')
		@value = View::Ticker.new(model, @session, self)
	end
end
class MorphopolisTickerContainer < HtmlGrid::DivComposite
	CSS_ID = 'ticker-container'
	COMPONENTS = {
		[0,0]	=>	MorphopolisTicker
	}
end
class WorkTitle < HtmlGrid::Div
	CSS_CLASS = 'table-title center'
	def init
		super
		img = HtmlGrid::Image.new(:work_title, model, @session, self)
		@value = img 
	end
end
class WorkText < HtmlGrid::DivList 
	CSS_CLASS = 'intro-text'
	COMPONENTS = {
		[0,0]	=>	View::TextBlock,
	}
end
class WorkComposite < HtmlGrid::DivComposite
	CSS_CLASS = 'content'
	COMPONENTS = {
		[0,0]	=>	WorkTitle,	
		[1,0]	=>	:oneliner,
		[2,0]	=>	WorkText,
		[3,0]	=>	:morphopolis_ticker_link,
	}
	def oneliner(model)
		model = @session.app.load_oneliner('hiswork')
		View::Works::OneLiner.new(model, @session, self)		
	end
	def work_text(model)
		model = @session.app.load_hiswork_text
		View::Personal::WorkText.new(model, @session, self)
	end
	def morphopolis_ticker_link(model)
		link = HtmlGrid::Link.new(:morphopolis_ticker_link, model, @session, self)
		link.href = "javascript:void(0)"
		link.attributes['onclick']	= 'toggleTicker();' 
		link.value = @lookandfeel.lookup(:morphopolis_ticker_link)
		div = HtmlGrid::Div.new(model, @session, self)
		div.css_id = 'ticker-link'
		div.value = link
		div	
	end
end
class Work < View::PersonalPublicTemplate
	CONTENT = View::Personal::WorkComposite
	TICKER = View::Personal::MorphopolisTickerContainer
end
		end
	end
end
