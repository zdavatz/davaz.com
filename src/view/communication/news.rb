#!/usr/bin/env ruby
# View::Communication::News -- davaz.com -- 06.09.2005 -- mhuggler@ywesee.com

require 'view/list'
require 'view/publictemplate'
require 'view/textblock'
require 'htmlgrid/divcomposite'
require 'htmlgrid/value'
require 'util/image_helper'
require 'view/admin/ajax_views'

module DAVAZ
	module View
		module Communication
class NewsList < HtmlGrid::DivList
	CSS_CLASS = 'news'
	COMPONENTS = {
		[0,0]	=>	View::TextBlock,
	}
end
class NewsTitle < HtmlGrid::Div
	CSS_CLASS = 'table-title'
	def init
		super
		span = HtmlGrid::Span.new(model, @session, self)
		span.css_class = 'table-title'
		span.value = @lookandfeel.lookup(:news_from_davaz)
		@value = span
	end
end
class NewsComposite < HtmlGrid::DivComposite
	CSS_CLASS = 'content'
	COMPONENTS = {
		[0,0]	=>	NewsTitle,
		[1,0]	=>	NewsList,	
	}
	CSS_MAP = {
		[1,0]	=>	'news-list',
	}
end
class News < View::CommunicationPublicTemplate
	CONTENT = View::Communication::NewsComposite	
end
class AdminNewsInnerComposite < HtmlGrid::DivComposite
	CSS_ID = "element-container"
	COMPONENTS = {
		[0,0]	=>	component(View::AdminTextBlockList, :news),
	}
end
class AdminNewsComposite < View::Communication::NewsComposite
	COMPONENTS = {
		[0,0]	=>	NewsTitle,
		[1,0]	=>	View::Admin::AjaxAddNewElementComposite,
		[2,0]	=>	AdminNewsInnerComposite,	
	}
end
class AdminNews < View::CommunicationAdminPublicTemplate
	CONTENT = View::Communication::AdminNewsComposite
end
		end
	end
end
