#!/usr/bin/env ruby
# View::Personal::Work -- davaz.com -- 27.09.2005 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/textblock'
require 'view/works/oneliner'
require 'htmlgrid/divcomposite'
require 'htmlgrid/image'
require 'view/admin/ajax_views'

module DAVAZ
	module View
		module Personal
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
		[1,0]	=>	component(View::Works::OneLiner, :oneliner),
		[2,0]	=>	:morphopolis_ticker_link,
		[3,0]	=>	component(WorkText, :text),
	}
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
	TICKER = 'morphopolis'
end
class AdminWorkTextInnerComposite < HtmlGrid::DivComposite 
	CSS_ID = "element-container"
	COMPONENTS = {
		[0,0]	=>	component(View::AdminTextBlockList, :text),
	}
end
class AdminWorkComposite < WorkComposite 
	COMPONENTS = {
		[0,0]	=>	WorkTitle,	
		[1,0]	=>	component(View::Works::OneLiner, :oneliner),
		[2,0]	=>	:morphopolis_ticker_link,
		[3,0]	=>	View::Admin::AjaxAddNewElementComposite,
		[4,0]	=>	AdminWorkTextInnerComposite,
	}
end
class AdminWork < View::AdminPersonalPublicTemplate
	CONTENT = View::Personal::AdminWorkComposite
	TICKER = 'morphopolis'
end
		end
	end
end
