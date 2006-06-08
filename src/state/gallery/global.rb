#!/usr/bin/env ruby
# State::Gallery::Global -- davaz.com -- 06.06.2006 -- mhuggler@ywesee.com

require 'state/global'
require 'state/gallery/artobject'
require 'state/gallery/result'
require 'state/gallery/search'

module DAVAZ
	module State
		module Gallery
class Global < State::Global
	HOME_STATE = State::Personal::Init
	ZONE = :gallery
	GLOBAL_MAP = {
		:artobject			=>	State::Gallery::ArtObject,
		:search					=>	State::Gallery::Search,
		:ajax_search		=>	State::Gallery::AjaxSearch,
	}
end
		end
	end
end
