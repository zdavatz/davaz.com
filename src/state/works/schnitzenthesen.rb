#!/usr/bin/env ruby
# State::Works::Schnitzenthesen -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/works/schnitzenthesen'

module DAVAZ
	module State
		module Works
class Schnitzenthesen < State::Works::RackState
	VIEW = View::Works::Schnitzenthesen
	ARTGROUP_ID = 'SCH'
end
class AdminSchnitzenthesen < State::Works::AdminRackState
	VIEW = View::Works::AdminSchnitzenthesen
	ARTGROUP_ID = 'SCH'
end
		end
	end
end
