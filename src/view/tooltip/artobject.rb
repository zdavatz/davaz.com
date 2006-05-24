#!/usr/bin/env ruby
# View::ToolTip::ArtObject -- davaz.com -- 10.05.2006 -- mhuggler@ywesee.com

require 'view/tooltip/tooltip'
require 'htmlgrid/image'
require 'htmlgrid/divcomposite'

module DAVAZ
	module View
		module ToolTip
class ArtObject < View::ToolTip::ToolTip
	COMPONENTS = {
		[0,0]	=>	:title,
		[0,1]	=>	:image,
		[0,2]	=>	:comment,
	}
	def image(model)
		display_id = model.display_id
		img = HtmlGrid::Image.new(display_id, model, @session, self)
		url = @lookandfeel.upload_image_path(display_id)
		img.attributes['src'] = url
		img.css_class = 'image-tooltip-image'
		img
	end
end
		end
	end
end
