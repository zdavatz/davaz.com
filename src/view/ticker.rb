#!/usr/bin/env ruby
# View::Ticker -- davaz.com -- 12.04.2006 -- mhuggler@ywesee.com

require 'htmlgrid/dojotoolkit'
require 'htmlgrid/component'
require 'util/image_helper'

module DAVAZ
	module View
		class Ticker < HtmlGrid::Component
			attr_accessor :component_width, :component_height
			def init
				@component_width = TICKER_COMPONENT_WIDTH
				@component_height = TICKER_COMPONENT_HEIGHT
				super
			end
			def to_html(context)
				args = {
					'images'					=>	[],
					'eventUrls'				=>	[],
					'windowWidth'			=>	780,
					'componentWidth'	=>	@component_width,
					'componentHeight'	=>	@component_height,
					'widgetId'				=>	'ticker',	
					'pause'						=>	true,
				}
				model.each { |item| 
					unless(item.artobject_id.nil?)
						path = DAVAZ::Util::ImageHelper.image_path(item.artobject_id, 'medium')
						args['images'].push(path)
						if(item.class == DAVAZ::Model::ArtObject)
							event_args = {
								'artobject_id'	=>	item.artobject_id,
							}
						else
							event_args = {
								'artobject_id'	=>	item.artobject_id,
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
		class InnerTicker < HtmlGrid::Div
			CSS_ID = 'ticker'
			def init
				super
				@value = View::Ticker.new(@model, @session, self)
				@value.component_height = 135
				@value.component_width = 180
			end
		end
		class TickerContainer < HtmlGrid::DivComposite
			CSS_ID = 'ticker-container'
			COMPONENTS = {
				[0,0]	=>	InnerTicker,
			}
		end
	end
end
