#!/usr/bin/env ruby
# State::Works::Drawings -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'state/works/rack_state'
require 'view/works/drawings'

module DAVAZ
	module State
		module Works
class AdminDrawings < State::Works::AdminRackState
	VIEW = View::Works::AdminDrawings
	ARTGROUP_ID = 'DRA'
end
class Drawings < State::Works::RackState
	VIEW = View::Works::Drawings
	ARTGROUP_ID = 'DRA'
end
class AjaxDrawings < State::Works::RackState
	VIEW = View::Works::Drawings
	ARTGROUP_ID = 'DRA'
	VOLATILE = true
end
		end
	end
end
