#!/usr/bin/env ruby
# State::Gallery::ArtObject -- davaz.com -- 07.06.2006 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/gallery/artobject'

module DAVAZ
	module State
		module Gallery
class ArtObject < State::Gallery::Global 
	VIEW = View::Gallery::ArtObject	
	def init
		artobject_id = @session.user_input(:artobject_id)
		artgroup_id = @session.user_input(:artgroup_id)
		query = @session.user_input(:search_query)
		@model = @session.app.search_artobjects(query, artgroup_id)
		object = @model.find { |artobject| 
			artobject.artobject_id == artobject_id
		} 
		@session[:active_object] = object
	end
end
		end
	end
end
