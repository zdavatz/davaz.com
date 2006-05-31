#!/usr/bin/env ruby
# View::ToolTip::Image -- davaz.com -- 14.03.2006 -- mhuggler@ywesee.com

require 'view/tooltip/tooltip'
require 'htmlgrid/image'
require 'htmlgrid/divcomposite'
require 'util/image_helper'

module DAVAZ
	module View
		module ToolTip
class ImageComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	:image,
		[0,1]	=>	:text,
	}
	CSS_MAP = {
		0	=>	'image-tooltip-image',
		1	=>	'image-tooltip-text',
	}
	def image(model)
		display_id = model.display_id
		img = HtmlGrid::Image.new(display_id, model, @session, self)
		url = DAVAZ::Util::ImageHelper.image_path(display_id)
		img.set_attribute('src', url)
		img.set_attribute('style', "max-width: #{LARGE_IMAGE_WIDTH};")
		img.css_class = 'image-tooltip-image'
		img
	end
end
class Image < View::ToolTip::ToolTip 
	COMPONENTS = {
		[0,0] =>	ImageComposite,
	}
end
		end
	end
end
