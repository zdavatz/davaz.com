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
				@component_width = DAVAZ.config.ticker_component_width
				@component_height = DAVAZ.config.ticker_component_height
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
					'stopped'					=>	'true',
				}
				model.each { |item| 
					unless(item.artobject_id.nil?)
						if(Util::ImageHelper.has_image?(item.artobject_id))
							path = Util::ImageHelper.image_url(item.artobject_id, 'medium')
							args['images'].push(path)
							event_args = [
								[ 'artgroup_id' , item.artgroup_id ],
								[ 'artobject_id', item.artobject_id ]
							]
							unless(item.url.nil? || item.url.empty?)
								event_url = item.url
							else
								event_url = @lookandfeel.event_url(:gallery, :art_object, \
																															event_args)
							end
							args['eventUrls'].push(event_url)
						end
					end
				}
				dojo_tag('ticker', args).to_html(context)
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
