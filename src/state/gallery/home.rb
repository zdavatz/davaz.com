#!/usr/bin/env ruby
# State::Gallery::Home -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/gallery/home'
require 'view/ajax_response'

module DAVAZ
	module State
		module Gallery 
class AjaxToggleRack < SBSM::State
	VOLATILE = true
	#VIEW = View::SearchSlideShowRackComposite
	VIEW = View::AjaxResponse
	def init
		serie_id = @session.user_input(:serie_id)
		#@model = @session.load_serie(serie_id)
		images = []	
		titles = []	
		@session.load_serie(serie_id).each { |slide|
			image = DAVAZ::Util::ImageHelper.image_path(slide.display_id, 'slideshow')
			images.push(image)
			titles.push(slide.title)
		}
		@model = {
			'images'			=>	images,
			'titles'			=>	titles,
			'imageHeight'	=>	SLIDESHOW_IMAGE_HEIGHT,
		}
	end
end
class AjaxToggleSlideshow < AjaxToggleRack ; end
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
