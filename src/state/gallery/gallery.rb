#!/usr/bin/env ruby
# State::Gallery::Gallery -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'state/art_object'
require 'view/gallery/gallery'
require 'view/art_object'
require 'view/rack_art_object'
require 'view/ajax_response'

module DAVAZ
	module State
		module Gallery 
class AjaxAdminDeskArtobject < SBSM::State
	include AdminArtObjectMethods
	VIEW = View::AdminRackArtObjectComposite
	VOLATILE = true
	def init
		@model = OpenStruct.new
		artobject_id = @session.user_input(:artobject_id)
		serie_id = @session.user_input(:serie_id)
		serie	= @session.load_serie(serie_id) 
		@model.artobjects = serie.artobjects
		object = @model.artobjects.find { |artobject| 
			artobject.artobject_id == artobject_id
		} 
		@model.artobject = object 
		@model.fragment = "Desk_#{serie_id}_#{artobject_id}"
		build_selections
	end
end
class AjaxDeskArtobject < SBSM::State
	VIEW = View::RackArtObjectComposite
	VOLATILE = true
	def init
		@model = OpenStruct.new
		artobject_id = @session.user_input(:artobject_id)
		serie_id = @session.user_input(:serie_id)
		serie	= @session.load_serie(serie_id) 
		@model.artobjects = serie.artobjects
		object = @model.artobjects.find { |artobject| 
			artobject.artobject_id == artobject_id
		} 
		@model.artobject = object 
	end
end
class AjaxDesk < SBSM::State
	VIEW = View::Gallery::RackResultListComposite
	VOLATILE = true
	def init
		serie_id = @session.user_input(:serie_id)
		@model = @session.app.load_serie(serie_id).artobjects
	end
end
class AjaxRack < SBSM::State
	VOLATILE = true
	VIEW = View::AjaxResponse
	def init
		serie_id = @session.user_input(:serie_id)
		artobject_ids = []	
		images = []	
		titles = []	
		@session.load_serie(serie_id).artobjects.each { |artobject|
			if(Util::ImageHelper.has_image?(artobject.artobject_id))
				image = Util::ImageHelper.image_url(artobject.artobject_id, 'slideshow')
				images.push(image)
				titles.push(artobject.title)
				artobject_ids.push(artobject.artobject_id)
			end
		}
		@model = {
			'artObjectIds'	=>	artobject_ids,
			'images'				=>	images,
			'titles'				=>	titles,
			'imageHeight'		=>	DAVAZ.config.slideshow_image_height,
			'serieId'				=>	serie_id,
		}
		@filter = Proc.new { |model|
			model.store('dataUrl', @request_path)
			model
		}
	end
end
class Gallery < State::Gallery::Global
	VIEW = View::Gallery::Gallery
	def init
		@model = OpenStruct.new
		@model.oneliner = @session.app.load_oneliner('index')
		@model.series = @session.app.load_series
		@model.artgroups = @session.app.load_artgroups
	end
end
class AdminGallery < State::Gallery::Gallery
	VIEW = View::Gallery::AdminGallery
	include AdminArtObjectMethods
end
		end
	end
end
