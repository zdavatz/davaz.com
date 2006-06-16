#!/usr/bin/env ruby
# State::Public::Articles -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/public/articles'
require 'view/public/article'

module DAVAZ
	module State
		module Public 
class AjaxArticle < SBSM::State
	VOLATILE = true
	VIEW = View::Public::ArticleComposite
	def init
		article_id = @session.user_input(:display_id)
		@model = @session.load_article(article_id)
		super
	end
end
class Articles < State::Public::Global
	VIEW = View::Public::Articles
	def init
		super
		@model = @session.load_articles 
	end
end
class AdminArticles < Articles
	VIEW = View::Public::AdminArticles
end
		end
	end
end
