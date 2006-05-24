#!/usr/bin/env ruby
# View::Ticker -- davaz.com -- 12.04.2006 -- mhuggler@ywesee.com

require 'htmlgrid/dojotoolkit'
require 'htmlgrid/component'

module DAVAZ
	module View
		class Ticker < HtmlGrid::Component
			def to_html(context)
				args = {
					'images'			=>	[],
					'eventUrls'		=>	[],
					'windowWidth'	=>	'780',
				}
				model.each { |item| 
					unless(item.display_id.nil?)
						path = @lookandfeel.upload_image_path(item.display_id)
						args['images'].push(path)
						if(item.class == DAVAZ::Model::ArtObject)
							event_args = {
								'artobject_id'	=>	item.artobject_id,
							}
						else
							event_args = {
								'display_id'	=>	item.display_id,
							}
						end
						event_url = @lookandfeel.event_url(:gallery, :view, \
							event_args)
						args['eventUrls'].push(event_url)
					end
				}
				dojo_tag('ticker', args)
			end
		end
	end
end
