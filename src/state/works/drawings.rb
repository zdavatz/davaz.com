#!/usr/bin/env ruby
# State::Works::Drawings -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/works/drawings'
require 'model/artobject'

module DAVAZ
	module State
		module Works
class Drawings < State::Works::Global
	VIEW = View::Works::Drawings
	ARTGROUP_ID = 'DRA'
end
		end
	end
end
