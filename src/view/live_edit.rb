#!/usr/bin/env ruby
# View::LiveEdit -- davaz.com -- 05.09.2006 -- mhuggler@ywesee.com

require 'htmlgrid/component'
require 'htmlgrid/dojotoolkit'

module DAVAZ
	module View
		class LiveEdit < HtmlGrid::NamedComponent
			def to_html(context)
				url = @lookandfeel.event_url(:admin, :ajax_save_live_edit)
				args = [
					[ 'artobject_id', @model.artobject_id ],
					[ 'field_key', @name ],
					[ 'value', @model.send(@name) ],
					[ 'css_class', "block-#{@name.to_s}" ],
					[ 'update_url', url ],
				]
				dojo_tag('liveedit', args)
			end
		end
	end
end

