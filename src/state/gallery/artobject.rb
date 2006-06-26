#!/usr/bin/env ruby
# State::Gallery::ArtObject -- davaz.com -- 07.06.2006 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/gallery/artobject'

module DAVAZ
	module State
		module Gallery
class AjaxMovieGallery < SBSM::State
	VIEW = View::Gallery::MoviesArtObjectComposite
	VOLATILE = true
	def init
		@model = OpenStruct.new
		artobject_id = @session.user_input(:artobject_id)
		@model.artobjects	= @session.load_movies
		object = @model.artobjects.find { |artobject| 
			artobject.artobject_id == artobject_id
		} 
		@model.artobject = object 
	end
end
class ArtObject < State::Gallery::Global 
	VIEW = View::Gallery::ArtObject	
	def init
		artobject_id = @session.user_input(:artobject_id)
		artgroup_id = @session.user_input(:artgroup_id)
		query = @session.user_input(:search_query)
		@model = OpenStruct.new
		@model.artobjects = @session.app.search_artobjects(query, artgroup_id)
		object = @model.artobjects.find { |artobject| 
			artobject.artobject_id == artobject_id
		} 
		@model.artobject = object
	end
end
		end
	end
end
