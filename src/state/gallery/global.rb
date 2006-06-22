#!/usr/bin/env ruby
# State::Gallery::Global -- davaz.com -- 06.06.2006 -- mhuggler@ywesee.com

require 'state/global'
require 'state/gallery/artobject'
require 'state/gallery/result'
require 'state/gallery/home'

module DAVAZ
	module State
		module Gallery
class Global < State::Global
	HOME_STATE = State::Gallery::Home
	ZONE = :gallery
	EVENT_MAP = {
		:artobject		=>	State::Gallery::ArtObject,
		:home					=>	State::Gallery::Home,
	}
end
		end
	end
end
