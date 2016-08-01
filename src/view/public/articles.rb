#!/usr/bin/env ruby
# View::Public::Articles -- davaz.com -- 28.09.2005 -- mhuggler@ywesee.com

require 'view/template'
require 'view/_partial/textblock'
require 'htmlgrid/divcomposite'
require 'htmlgrid/divlist'
require 'htmlgrid/input'

module DaVaz
	module View
		module Public
class ArticlesList < HtmlGrid::DivList
	COMPONENTS = {
		[0,0]	=>	:title,
		[0,1]	=>	:author,
		[0,2]	=>	:article,
	}
	CSS_MAP = {
		0	=>	'article-title',
		1	=>	'article-author',
		2	=>	'article-text',
	}
	def title(model)
		link = HtmlGrid::Link.new('toggle-article', model, @session, self)
		link.href = 'javascript:void(0)'
		args = [ :artobject_id, model.artobject_id ]
		url = @lookandfeel.event_url(:article, :ajax_article, args)
		link.set_attribute('onclick', "toggleArticle(this, '#{model.artobject_id}', '#{url}')")
		link.value = model.title 
		link
	end
	def article(model)
		div = HtmlGrid::Div.new(model, @session, self)
		div.css_id = model.artobject_id
		div.set_attribute('style', 'display: none;')
		div
	end
end
class ArticlesTitle < HtmlGrid::Div
	CSS_CLASS = 'table-title'
	def init
		super
		span = HtmlGrid::Span.new(model, @session, self)
		span.css_class = 'table-title'
		span.value = @lookandfeel.lookup(:articles)
		@value = span
	end
end
class ArticlesComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=> ArticlesTitle,	
		[1,0]	=> ArticlesList,	
	}
end
class Articles < View::ArticlesTemplate
	CONTENT = View::Public::ArticlesComposite 
end
class AdminArticlesList < ArticlesList 
	def title(model)
		super
	end
end
class AdminArticlesComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	ArticlesTitle,
		[1,0]	=>	AdminArticlesList,
	}
end
class AdminArticles < View::ArticlesTemplate 
	CONTENT = AdminArticlesComposite
end
		end
	end
end
