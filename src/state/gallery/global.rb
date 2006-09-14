#!/usr/bin/env ruby
# State::Gallery::Global -- davaz.com -- 06.06.2006 -- mhuggler@ywesee.com

require 'state/global'
require 'state/gallery/result'
require 'state/gallery/gallery'

module DAVAZ
	module State
		module Gallery
class Global < State::Global
	HOME_STATE = State::Gallery::Gallery
	ZONE = :gallery
	EVENT_MAP = {
		:gallery						=>	State::Gallery::Gallery,
	}
end
		end
	end
end
