#!/usr/bin/env ruby
# State::Works::Photos -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/works/photos'

module DAVAZ
	module State
		module Works
class Photos < State::Works::RackState
	VIEW = View::Works::Photos
	ARTGROUP_ID = 'PHO'
end
		end
	end
end
