#!/usr/bin/env ruby
# State::Communication::News -- davaz.com -- 06.09.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/communication/news'
require 'view/admin/live_edit'
require 'state/admin/ajax_states'

module DAVAZ
	module State
		module Communication 
class News < State::Communication::Global
	VIEW = View::Communication::News
	def init
		@model = @session.app.load_news
	end
end
class AjaxAddNewElement < State::Admin::AjaxAddNewElement 
	def init
		values = {
			:serie_id =>	@model.serie_id,
			:url			=>	@session.lookandfeel.lookup(:click2edit), 
			:date			=>	Date.today.to_s, 
			:text			=>	@session.lookandfeel.lookup(:click2edit), 
		}		
		insert_id = @session.app.insert_artobject(values)
		@model = @session.app.load_artobject(insert_id)
	end
end
class AdminNews < State::Communication::News
	VIEW = View::Communication::AdminNews
	def init
		@model = OpenStruct.new
		@model.news = @session.app.load_news
		@model.serie_id = @session.app.load_serie_id('site_news')
	end
	def ajax_add_new_element
		AjaxAddNewElement.new(@session, @model)
	end
end
		end
	end
end
