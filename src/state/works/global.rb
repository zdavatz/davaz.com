#!/usr/bin/env ruby
# State::Works::Global -- davaz.com -- 29.08.2005 -- mhuggler@ywesee.com

require 'state/works/design'
require 'state/works/drawings'
require 'state/works/multiples'
require 'state/works/paintings'
require 'state/works/photos'
require 'state/works/rack_state'
require 'state/works/schnitzenthesen'
require 'state/works/movies'
require 'view/ajax_response'
require 'view/gallery/result'

module DAVAZ
	module State
		module Works 
=begin
class AjaxGlobal < Works::Global
	VOLATILE = true
	VIEW = View::AjaxResponse
	def init
		@model = @model.serie_items
	end
	def artgroup_id
		@session.user_input(:artgroup_id)
	end
end
=end
class Global < State::Global
	HOME_STATE = State::Personal::Init
	ZONE = :works
	EVENT_MAP = {
		:ajax_multiples				=>	State::Works::AjaxMultiples,
		:design								=>	State::Works::Design,
		:drawings							=>	State::Works::Drawings,
		:multiples						=>	State::Works::Multiples,
		:paintings						=>	State::Works::Paintings,
		:photos								=>	State::Works::Photos,
		:schnitzenthesen			=>	State::Works::Schnitzenthesen,
		:movies								=>	State::Works::Movies,
	}
end
		end
	end
end
