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
					'transitionInterval'	=>	'1500',
					'delay'		=> '3500',
					'imageHeight'	=>	DAVAZ.config.slideshow_image_height,
					#'id'			=>	@name.to_s,
					'id'			=>	'show',
          'dataUrl' =>  @lookandfeel.event_url(@session.zone, :ajax_images),
				}
			end
			def to_html(context)
				args = compose_args.update(@model)
        args.delete("images") # titles don't parse cleanly in dojo 0.9, so we 
        args.delete("titles") # pass images and titles by json
				dojo_tag("ywesee.widget.#@name", compose_args).to_html(context)
			end
		end
	end
end
