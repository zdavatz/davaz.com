#!/usr/bin/env ruby
# View::SerieLinks -- davaz.com -- 14.10.2005 -- mhuggler@ywesee.com

require 'htmlgrid/spanlist'
require 'htmlgrid/link'

module DAVAZ
	module View
		class SerieLinks < HtmlGrid::SpanList
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
				args = [ :serie_id, model.serie_id ]
				url = @lookandfeel.event_url(:gallery, :ajax_rack, args)
				script = "toggleShow('show', '#{url}', null);"
				link.set_attribute('onclick', script);
				link
			end
		end
	end
end
