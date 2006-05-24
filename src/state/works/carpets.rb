#!/usr/bin/env ruby
# State::Works::Carpets -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/works/carpets'

module DAVAZ
	module State
		module Works
class Carpets < State::Works::Global
	VIEW = View::Works::Carpets
	ARTGROUP_ID = 'CAR'
end
		end
	end
end
