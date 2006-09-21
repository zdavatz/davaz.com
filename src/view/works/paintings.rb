#!/usr/bin/env ruby
# View::Works::Paintings -- davaz.com -- 28.09.2005 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/works/works'

module DAVAZ
	module View
		module Works
class PaintingsComposite < View::Works::Works; end
class Paintings < View::PaintingsPublicTemplate
	CONTENT = View::Works::PaintingsComposite 
end
class AdminPaintings < View::AdminPaintingsPublicTemplate
	CONTENT = View::Works::PaintingsComposite 
end
		end
	end
end
