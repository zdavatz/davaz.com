#!/usr/bin/env ruby
# State::Gallery::Home -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/gallery/home'
require 'view/art_object'
require 'view/rack_art_object'
require 'view/ajax_response'

module DAVAZ
	module State
		module Gallery 
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
	#VIEW = View::SearchSlideShowRackComposite
	VIEW = View::AjaxResponse
	def init
		serie_id = @session.user_input(:serie_id)
		#@model = @session.load_serie(serie_id)
		images = []	
		titles = []	
		@session.load_serie(serie_id).artobjects.each { |artobject|
			image = DAVAZ::Util::ImageHelper.image_path(artobject.artobject_id, 'slideshow')
			images.push(image)
			titles.push(artobject.title)
		}
		@model = {
			'images'			=>	images,
			'titles'			=>	titles,
			'imageHeight'	=>	SLIDESHOW_IMAGE_HEIGHT,
			'serieId'			=>	serie_id,
		}
		@filter = Proc.new { |model|
			model.store('dataUrl', @request_path)
			model
		}
	end
end
class Home < State::Gallery::Global
	VIEW = View::Gallery::Home
	def init
		@model = OpenStruct.new
		@model.oneliner = @session.app.load_oneliner('index')
		@model.series = @session.app.load_series
	end
end
		end
	end
end
