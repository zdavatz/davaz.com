#!/usr/bin/env ruby
# View::Slideshow-- davaz.com -- 11.10.2005 -- mhuggler@ywesee.com

require 'htmlgrid/dojotoolkit'
require 'htmlgrid/component'
require 'util/image_helper'

module DAVAZ
	module View
		class Slideshow < HtmlGrid::Component
			def to_html(context)
				args = {
					'images'	=> [],
					'titles'	=> [],
					'transitionInterval'	=>	'1500',
					'delay'		=> '3500',
					'imageHeight'	=>	SLIDESHOW_IMAGE_HEIGHT,
				}
				model.each { |slide|
					image = DAVAZ::Util::ImageHelper.image_path(slide.display_id, 'slideshow')
					if(slide.title=="?")
						title = "no title" 
					else
						title = slide.title
					end
					args['images'].push(image)
					args['titles'].push(title)
				}
				dojo_tag('slideshow', args)
			end
		end
	end
end
