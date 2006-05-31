#!/usr/bin/env ruby
# View::Communication::News -- davaz.com -- 06.09.2005 -- mhuggler@ywesee.com

require 'view/list'
require 'view/publictemplate'
require 'htmlgrid/divcomposite'
require 'htmlgrid/value'
require 'util/image_helper'

module DAVAZ
	module View
		module Communication
class NewsList < View::List
	DEFAULT_CLASS = HtmlGrid::Value
	OMIT_HEADER = true
	OFFSET_STEP = [0,2]
	STRIPED_BG = false
	CSS_ID = 'news-list'
	COMPONENTS = {
		[0,0]	=>	:title,
		[1,0]	=>	:date,
		[0,1]	=>	:text,
		[1,1]	=>	:image,
	}
	CSS_MAP = {
		[0,0]	=>	'news-title',
		[1,0]	=>	'news-date',
		[0,1]	=>	'news-text',
		[1,1]	=>	'news-image',
	}
	def image(model)
		unless(model.to_display_id.nil?)
			img = HtmlGrid::Image.new('news-image', model, @session, self) 
			url = DAVAZ::Util::ImageHelper.image_path(model.to_display_id, 'medium')
			img.set_attribute('src', url)
			img.set_attribute('width', MEDIUM_IMAGE_WIDTH)
			img
		end
	end
	def date(model)
		#model.date.strftime("%d.%m.%Y")
		model.date
	end
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
		end
	end
end
