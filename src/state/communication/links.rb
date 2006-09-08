#!/usr/bin/env ruby
# State::Communication::Links -- davaz.com -- 12.09.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'state/admin/ajax_states'
require 'view/communication/links'
require 'view/textblock'
require 'view/ajax_response'
require 'date'

module DAVAZ
	module State
		module Communication
class Links < State::Communication::Global
	VIEW = View::Communication::Links
	def init
		@model = @session.app.load_links
	end
end
class AjaxDeleteElement < SBSM::State 
	VIEW = View::AjaxResponse
	VOLATILE = true
	def init
		artobject_id = @session.user_input(:artobject_id)
		@session.app.delete_artobject(artobject_id)
		url = @session.lookandfeel.event_url(:communication, :links)
		@model = Hash.new
		@model['url'] = url
	end
end
class AjaxAddNewElement < SBSM::State 
	VIEW = View::AdminTextBlock
	VOLATILE = true
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
class AdminLinks < State::Communication::Global
	VIEW = View::Communication::AdminLinks
	def init
		@model = OpenStruct.new
		@model.links = @session.app.load_links
		@model.fields = [ :url, :date, :text ]
		@model.serie_id = @session.app.load_serie_id('site_links')
	end
	def ajax_add_new_element
		AjaxAddNewElement.new(@session, @model)
	end
	def ajax_delete_element
		AjaxDeleteElement.new(@session, @model)
	end
end
		end
	end
end
