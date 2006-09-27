#!/usr/bin/env ruby
# View::Slideshow-- davaz.com -- 11.10.2005 -- mhuggler@ywesee.com

require 'htmlgrid/dojotoolkit'
require 'htmlgrid/component'
require 'util/image_helper'

module DAVAZ
	module View
		class SerieWidget < HtmlGrid::NamedComponent
			def compose_args
				{
					'images'	=> [],
					'titles'	=> [],
					'transitionInterval'	=>	'1500',
					'delay'		=> '3500',
					'imageHeight'	=>	DAVAZ.config.slideshow_image_height,
					#'id'			=>	@name.to_s,
					'id'			=>	'show',
				}
			end
			def to_html(context)
				args = compose_args.update(@model)
				dojo_tag(@name, args)
			end
		end
	end
end
