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
		article_id = @session.user_input(:artobject_id)
		@model = @session.load_article(article_id)
	end
end
class Articles < State::Public::Global
	VIEW = View::Public::Articles
	def init
		@model = @session.load_articles 
		@model.each { |article|
			article.text = ""
		}
	end
end
class AdminArticles < Articles
	VIEW = View::Public::AdminArticles
end
		end
	end
end
