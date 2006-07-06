#!/usr/bin/env ruby
# State::Works::Paintings -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/works/paintings'

module DAVAZ
	module State
		module Works
class Paintings < State::Works::RackState
	VIEW = View::Works::Paintings
	ARTGROUP_ID = "PAI"
end
		end
	end
end
