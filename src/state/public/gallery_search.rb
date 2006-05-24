#!/usr/bin/env ruby
# State::Public::GallerySearch -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/public/gallery_search'

module DAVAZ
	module State
		module Public 
class GallerySearch < State::Public::Global
	VIEW = View::Public::GallerySearch
end
		end
	end
end
