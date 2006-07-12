#!/usr/bin/env ruby
# View::Works::Works -- davaz.com -- 05.05.2006 -- mhuggler@ywesee.com

require 'htmlgrid/divcomposite'
require 'view/serie_links'
require 'view/slideshowrack'
require 'view/add_onload'

module DAVAZ
	module View
		module Works
class WorksTitle < HtmlGrid::Div
	CSS_CLASS = 'table-title'
	def init
		super
		span = HtmlGrid::Span.new(model, @session, self)
		span.css_class = 'table-title'
		span.value = @lookandfeel.lookup(@session.event)
		@value = span
	end
end
class Works < HtmlGrid::DivComposite
	include SerieLinks
	CSS_CLASS = 'content'
	COMPONENTS = {
		[0,0]	=>	WorksTitle,
		[0,1]	=>	SlideShowRackComposite,
		[0,2]	=>	:series,
		[0,3] =>	AddOnloadShow,
	}
	CSS_ID_MAP = {
		1	=>	'show-wipearea',
		2	=>	'serie-links',
	}
	def series(model)
		model.series.collect { |name|
			serie_link(name, 'null')
		}
	end
end
		end
	end
end
