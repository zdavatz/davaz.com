#!/usr/bin/env ruby
# View::Article -- davaz.com -- 27.03.2006 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/divlist'

module DAVAZ
	module View
		module Public
class ArticleComposite < HtmlGrid::DivComposite
	CSS_CLASS = 'content'
	COMPONENTS = {
		[0,0]	=>	:close_article,
		[1,0]	=>	:anchor,
		[2,0]	=>	:text,
		[3,0]	=>	:close_article,
	}
	HTTP_HEADERS = {
		"type"		=>	"text/html",
		"charset"	=>	"UTF-8",
	}			
	def anchor(model)
		HtmlGrid::Link.new(model.artobject_id, model, @session, self)
	end
	def text(model)
		model.text
	end
	def close_article(model)
		link = HtmlGrid::Link.new('toggle-article', model, @session, self)
		link.href = 'javascript:void(0)'
		div_id = model.artobject_id
		url = @lookandfeel.event_url(:article, :ajax_article, div_id)
		link.set_attribute('onclick', "toggleArticle(this, '#{div_id}', '#{url}')")
		link.value = @lookandfeel.lookup(:close_article) 
		link.css_class = 'close-link'
		link
	end
	def http_headers
		headers = super
		charset = @model.charset
		unless(charset.empty?)
			headers.store('Content-Type', "text/html; charset=#{charset}")
		end
		headers
	end
end
		end
	end
end
