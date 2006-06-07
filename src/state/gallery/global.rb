#!/usr/bin/env ruby
# State::Gallery::Global -- davaz.com -- 06.06.2006 -- mhuggler@ywesee.com

require 'state/global'
require 'state/gallery/result'

module DAVAZ
	module State
		module Gallery
class Global < State::Global
	HOME_STATE = State::Personal::Init
	ZONE = :gallery
end
		end
	end
end
