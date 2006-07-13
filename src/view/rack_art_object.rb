#!/usr/bin/env ruby
# View::RackArtObject -- davaz.com -- 03.07.2006 -- mhuggler@ywesee.com

require 'view/art_object'

module DAVAZ
	module View
		class RackPager < Pager 
			def pager_link(link)
				artobject_id = link.attributes['href'].split("/").last
				serie_id = @session.user_input(:serie_id) 
				args = [ 
					[ :serie_id, serie_id ],
					[ :artobject_id, artobject_id ],
				]
				url = @lookandfeel.event_url(:gallery, :ajax_rack, args)
				link.href = "javascript:void(0)"
				script = "toggleShow('show', '#{url}', 'Desk', null, '#{serie_id}', '#{artobject_id}');"
				link.set_attribute('onclick', script)
				link
			end
			def next(model)
				unless((link = super).nil?)
					link = super
					pager_link(link)
				end
			end
			def last(model)
				unless((link = super).nil?)
					link = super
					pager_link(link)
				end
			end
		end
		class RackArtObjectOuterComposite < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]	=>	RackPager,
				[0,1]	=>	:back_to_overview,
			}
			CSS_ID_MAP = {
				0	=>	'artobject-pager',
				1	=>	'artobject-back-link',
			}
			def back_to_overview(model)
				link = HtmlGrid::Link.new(:back_to_overview, model, @session, self)
				link.href = "javascript:void(0)" 
				serie_id = @session.user_input(:serie_id) 
				args = [ 
					[ :serie_id, serie_id ],
				]
				url = @lookandfeel.event_url(:gallery, :ajax_rack, args)
				script = "toggleShow('show','#{url}','Desk','show-wipearea');"
				link.set_attribute('onclick', script) 
				link
			end
		end
		class RackArtObjectComposite < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]	=>	RackArtObjectOuterComposite,
				[0,1]	=>	component(ArtObjectInnerComposite, :artobject),
			}
			CSS_ID_MAP = {
				0	=>	'artobject-outer-composite',
				1	=>	'artobject-inner-composite',
			}
			HTTP_HEADERS = {
		"type"		=>	"text/html",
		"charset"	=>	"UTF-8",
			}			
		end
	end
end
