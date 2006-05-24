#!/usr/bin/env ruby
# View::Slideshow-- davaz.com -- 11.10.2005 -- mhuggler@ywesee.com

require 'htmlgrid/dojotoolkit'
require 'htmlgrid/component'

module DAVAZ
	module View
		class Slideshow < HtmlGrid::Component
			def to_html(context)
				args = {
					'images'	=> [],
					'titles'	=> [],
					'transitionInterval'	=>	'1500',
					'delay'		=> '3500',
				}
				model.each { |slide|
					image = @lookandfeel.upload_image_path(slide.display_id)
					if(slide.comment=="?")
						comment = "no title" 
					else
						comment = slide.comment
					end
					args['images'].push(image)
					args['titles'].push(comment)
				}
				dojo_tag('slideshow', args)
			end
		end
	end
end
