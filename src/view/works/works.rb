#!/usr/bin/env ruby
# View::Works::Works -- davaz.com -- 05.05.2006 -- mhuggler@ywesee.com

require 'htmlgrid/divcomposite'
require 'view/serie_links'
require 'view/slideshowrack'
require 'view/add_onload_show'

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
	CSS_CLASS = 'content'
	COMPONENTS = {
		[0,0]	=>	WorksTitle,
		[0,1]	=>	SlideShowRackComposite,
		[0,2]	=>	component(SerieLinks, :series),
		[0,3] =>	View::AddOnloadShow,
	}
	CSS_ID_MAP = {
		1	=>	'show-wipearea',
		2	=>	'serie-links',
	}
end
		end
	end
end
