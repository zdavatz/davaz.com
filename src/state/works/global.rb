#!/usr/bin/env ruby
# State::Works::Global -- davaz.com -- 29.08.2005 -- mhuggler@ywesee.com

require 'state/works/design'
require 'state/works/drawings'
require 'state/works/multiples'
require 'state/works/paintings'
require 'state/works/photos'
require 'state/works/schnitzenthesen'
require 'state/works/movies'

module DAVAZ
	module State
		module Works 
class Global < State::Global
	HOME_STATE = State::Personal::Init
	ZONE = :works
	ARTGROUP_ID = nil
	GLOBAL_MAP = {
		:design								=>	State::Works::Design,
		:drawings							=>	State::Works::Drawings,
		:multiples						=>	State::Works::Multiples,
		:paintings						=>	State::Works::Paintings,
		:photos								=>	State::Works::Photos,
		:schnitzenthesen			=>	State::Works::Schnitzenthesen,
		:movies								=>	State::Works::Movies,
	}
	def init
		serie_id = @session.user_input(:serie_id) 
		if(serie_id.nil?)
			series = @session.app.load_series_by_artgroup(artgroup_id)
			unless(series.empty?)
				serie_id = series.first.serie_id
			end
		end
		@model = @session.app.load_serie_objects(Model::ArtObject, artgroup_id, serie_id)
		super
	end
	def artgroup_id
		self.class.const_get(:ARTGROUP_ID)
	end
end
		end
	end
end
