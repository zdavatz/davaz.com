#!/usr/bin/env ruby
# View::Images -- davaz.com -- 27.03.2006 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/divlist'
require 'util/image_helper'

module DAVAZ
	module View
		class ImagesList < HtmlGrid::DivList
			COMPONENTS = {
				[0,0]	=> :image,
				[0,1]	=> :text,
			}
			CSS_MAP = {
				0	=>	'image',
				1	=>	'comment',
			}
			def image(model)
				artobject_id = model.artobject_id
				img = HtmlGrid::Image.new(artobject_id, model, @session, self)
				url = DAVAZ::Util::ImageHelper.image_url(artobject_id)
				img.attributes['src'] = url
				img.css_class = 'tooltip-image'
				img
			end
		end
		class ImagesComposite < HtmlGrid::DivComposite
			CSS_CLASS = 'content'
			COMPONENTS = {
				[0,0]	=>	'history_back_link',
				[1,0]	=>	ImagesList,
				[2,0]	=>	'history_back_link',
			}
		end
		class Images < View::ImagesPublicTemplate
			CONTENT = View::ImagesComposite
		end
	end
end
