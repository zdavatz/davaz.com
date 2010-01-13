#!/usr/bin/env ruby
# State::Works::Movies -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/works/movies'

module DAVAZ
	module State
		module Works
class AjaxAdminMovieGallery < SBSM::State
	include AdminArtObjectMethods
	VIEW = View::AdminMoviesArtObjectComposite
	VOLATILE = true
	def init
		@model = OpenStruct.new
		artobject_id = @session.user_input(:artobject_id)
		@model.artobjects	= @session.load_movies
		object = @model.artobjects.find { |artobject| 
			artobject.artobject_id == artobject_id
		} 
		@model.artobject = object 
		build_selections
	end
end
class AjaxMovieGallery < SBSM::State
	VIEW = View::MoviesArtObjectComposite
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
class AjaxUploadImage < SBSM::State
	include Magick
	VIEW = View::ImageDiv
	VOLATILE = true
	def init 
		@model = OpenStruct.new
		string_io = @session.user_input(:image_file)
		artobject_id = @session.user_input(:artobject_id)
		unless(string_io.nil?)
			if artobject_id
				Util::ImageHelper.store_upload_image(string_io, 
																						 artobject_id)
				@model.artobject = @session.app.load_artobject(artobject_id)
			#no 'else' => src/state/art_object handles new artobjects
			end
		end
	end
end
class Movies < State::Works::Global
	VIEW = View::Works::Movies
	def init
		@model = @session.load_movies()
	end
end
class AdminMovies < State::Works::Global
	VIEW = View::Works::AdminMovies
	def init
		@model = @session.load_movies()
	end
	def ajax_upload_image
		AjaxUploadImage.new(@session, @model)
	end
	def delete
		artobject_id = @session.user_input(:artobject_id)
		@session.app.delete_artobject(artobject_id)
		model = @session.lookandfeel.event_url(:works, :movies)
		State::Redirect.new(@session, model)
	end
	def update
		artobject_id = @session.user_input(:artobject_id)
		mandatory = [
			:title,
			:artgroup_id,
			:serie_id,
			:serie_position,
			:tool_id,
			:material_id,
			:date,
			:country_id,
		]
		keys = [
			:tags_to_s,
			:location,
			:form_language,
			:price,
			:size,
			:text,
			:url,
      :wordpress_url,
		].concat(mandatory)
		update_hash = {}
		user_input(keys, mandatory).each { |key, value|
			if(match = key.to_s.match(/(form_)(.*)/))
				update_hash.store(match[2].intern, value)
			elsif(key == :tags_to_s)
				if(value.nil?)
					update_hash.store(:tags, [])	
				else
					update_hash.store(:tags, value.split(','))	
				end
			elsif(key == :date)
				update_hash.store(:date, "#{value.year}-#{value.month}-#{value.day}")
			else
				update_hash.store(key, value)
			end	
		}
		unless(error?)
			if(artobject_id)
				@session.app.update_artobject(artobject_id, update_hash)
				model = @session.lookandfeel.event_url(:works, :movies)
				model << "##{artobject_id}"
				State::Redirect.new(@session, model)
			else
				insert_id = @session.app.insert_artobject(update_hash)
				image_path = @model.artobject.tmp_image_path
				Util::ImageHelper.store_tmp_image(image_path, insert_id)
				AjaxAdminMovieGallery.new(@session, [])
			end
		else
			model = @session.lookandfeel.event_url(:works, :movies)
			model << "##{artobject_id}"
			State::Redirect.new(@session, model)
		end
	end
end
		end
	end
end
