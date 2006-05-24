#!/usr/bin/env ruby
# State::Works::Design -- davaz.com -- 05.05.2006 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/works/design'

module DAVAZ
	module State
		module Works
class Design < State::Works::Global
	VIEW = View::Works::Design
	ARTGROUP_ID = 'DES'
end
		end
	end
end
