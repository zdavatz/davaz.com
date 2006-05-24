#!/usr/bin/env ruby
# View::Works::Works -- davaz.com -- 05.05.2006 -- mhuggler@ywesee.com

require 'htmlgrid/divcomposite'
require 'view/serielinks'
require 'view/slideshowrack'

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
		[0,2]	=>	:serie_links,
	}
	CSS_ID_MAP = {
		2	=>	'serie-links',
	}
	def serie_links(model)
		artgroup_id = @session.state.artgroup_id
		model = @session.app.load_series_by_artgroup(artgroup_id)
		View::SerieLinks.new(model, @session, self)
	end
end
		end
	end
end
