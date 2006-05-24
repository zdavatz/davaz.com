#!/usr/bin/env ruby
# View::Public::GallerySearch -- davaz.com -- 28.09.2005 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/divcomposite'

module DAVAZ
	module View
		module Public
class GallerySearchComposite < HtmlGrid::DivComposite
	CSS_CLASS = 'content'
	COMPONENTS = {}
end
class GallerySearch < View::GallerySearchPublicTemplate
	CONTENT = View::Public::GallerySearchComposite 
end
		end
	end
end
