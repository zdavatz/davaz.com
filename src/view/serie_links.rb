#!/usr/bin/env ruby
# View::SerieLinks -- davaz.com -- 14.10.2005 -- mhuggler@ywesee.com

require 'htmlgrid/spanlist'
require 'htmlgrid/link'

module DAVAZ
	module View
		class SerieLinks < HtmlGrid::SpanList
			REPLACE_ID = 'null'	
			COMPONENTS = {
				[0,0]	=>	:serie_link,
			}
			def serie_link(model)
				link = HtmlGrid::Link.new(:serie_link, model, @session, self)
				args = [ :serie_id, model.serie_id ]
				#link.href = @lookandfeel.event_url(:works, @session.event, args)
				link.href = 'javascript:void(0)'
				link.value = model.name + @lookandfeel.lookup('comma_divider')
				link.css_class = 'serie-link'
				link.css_id = model.serie_id
				args = [ :serie_id, model.serie_id ]
				url = @lookandfeel.event_url(:gallery, :ajax_rack, args)
				script = "toggleShow('show', '#{url}', null, '#{self.class::REPLACE_ID}', '#{model.serie_id}');"
				link.set_attribute('onclick', script);
				link
			end
		end
		class GallerySerieLinks < SerieLinks
			REPLACE_ID = 'upper-search-composite'	
		end
	end
end
