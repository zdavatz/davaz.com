#!/usr/bin/env ruby
# State::Works::Global -- davaz.com -- 29.08.2005 -- mhuggler@ywesee.com

require 'state/works/design'
require 'state/works/drawings'
require 'state/works/multiples'
require 'state/works/paintings'
require 'state/works/photos'
require 'state/works/schnitzenthesen'
require 'state/works/movies'
require 'view/ajax_response'

module DAVAZ
	module State
		module Works 
class AjaxGlobal < Works::Global
	VOLATILE = true
	VIEW = View::AjaxResponse
	def init
		super
		@model = @model.serie_items
	end
	def artgroup_id
		@session.user_input(:artgroup_id)
	end
end
class Global < State::Global
	HOME_STATE = State::Personal::Init
	ZONE = :works
	ARTGROUP_ID = nil
	GLOBAL_MAP = {
		:ajax_works_global		=>	State::Works::AjaxGlobal,
		:design								=>	State::Works::Design,
		:drawings							=>	State::Works::Drawings,
		:multiples						=>	State::Works::Multiples,
		:paintings						=>	State::Works::Paintings,
		:photos								=>	State::Works::Photos,
		:schnitzenthesen			=>	State::Works::Schnitzenthesen,
		:movies								=>	State::Works::Movies,
	}
	def init
		@model = OpenStruct.new
		serie_id = @session.user_input(:serie_id) 
		series = @session.app.load_series_by_artgroup(artgroup_id)
		@model.series = series
		if(serie_id.nil?)
			unless(series.empty?)
				serie_id = series.first.serie_id
			end
		end
		#@model = @session.app.load_serie_objects(Model::ArtObject, artgroup_id, serie_id)
		args = [ [ :serie_id, serie_id] ]
		args = [ [ :artgroup_id, artgroup_id] ]
		url = @session.lookandfeel.event_url(:works, :ajax_works_global, 
																				 args) 
		@model.serie_items = {
			'images'	=>	[],
			'titles'	=>	[],
			'dataUrl'	=>	url,
		}
		serie_items = @session.app.load_serie(serie_id)
		serie_items.each { |item|
			image = DAVAZ::Util::ImageHelper.image_path(item.display_id, 'slideshow')
			@model.serie_items['images'].push(image)
			@model.serie_items['titles'].push(item.title)
		}
		super
	end
	def artgroup_id
		self.class.const_get(:ARTGROUP_ID)
	end
end
		end
	end
end
