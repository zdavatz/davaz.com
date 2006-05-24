#!/usr/bin/env ruby
# View::ToolTip::Image -- davaz.com -- 14.03.2006 -- mhuggler@ywesee.com

require 'view/tooltip/tooltip'
require 'htmlgrid/image'
require 'htmlgrid/divcomposite'

module DAVAZ
	module View
		module ToolTip
class MoreImagesComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	:image,
		[0,1]	=>	:text, 
		[0,2]	=>	:more_link,
	}
	CSS_MAP = {
		0	=>	'image-tooltip-image',
		1	=>	'image-tooltip-text',
	}
	def image(model)
		display_id = model.display_id
		img = HtmlGrid::Image.new(display_id, model, @session, self)
		url = @lookandfeel.upload_image_path(display_id)
		img.attributes['src'] = url
		img.css_class = 'image-tooltip-image'
		img
	end
	def more_link(model)
		display_id = model.display_id
		link_id = model.link_id
		link = HtmlGrid::Link.new(display_id, @model, @session)
		args = [ :link_id, link_id ]
		link.href = @lookandfeel.event_url(:images, :images, args)
		link.value = @lookandfeel.lookup(:more_images)
		link
	end
end
class ImageList < HtmlGrid::DivList
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
		url = @lookandfeel.upload_image_path(display_id)
		img.attributes['src'] = url
		img.css_class = 'image-tooltip-image'
		img
	end
end
class Image < View::ToolTip::ToolTip 
	COMPONENTS = {
		[0,0] =>	:image_list,
	}
	def image_list(model)
		if(model.size > 1)
			View::ToolTip::MoreImagesComposite.new(model.first, @session, self)
		else
			View::ToolTip::ImageList.new(model, @session, self)
		end
	end
end
		end
	end
end
