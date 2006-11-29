#!/usr/bin/env ruby
# View::SerieLinks -- davaz.com -- 14.10.2005 -- mhuggler@ywesee.com

require 'htmlgrid/spanlist'
require 'htmlgrid/divlist'
require 'htmlgrid/link'

module DAVAZ
	module View
		module SerieLinks
			def serie_link(model, replace_id)
				link = HtmlGrid::Link.new(:serie_link, model, @session, self)
				args = [ :serie_id, model.serie_id ]
				#link.href = @lookandfeel.event_url(:works, @session.event, args)
				link.href = 'javascript:void(0)'
				link.value = model.name.gsub(' ', '&nbsp;')# << ', '
				link.css_class = 'serie-link'
				link.css_id = model.serie_id
				args = [ :serie_id, model.serie_id ]
				url = @lookandfeel.event_url(:gallery, :ajax_rack, args)
				script = "toggleShow('show', '#{url}', null, '#{replace_id}', '#{model.serie_id}');"
				link.set_attribute('onclick', script);
				link
			end
      def series(model, target)
        res = []
        model.series.each_with_index { |serie, idx|
          unless(serie.name.to_s.strip.empty?)
            unless(res.empty?)
              res.push(', ')
            end
            link = serie_link(serie, target)
            if(idx % 2 == 0)
              link.css_class << ' even'
            end
            res.push(link)
          end
        }
        res
      end
		end
	end
end
