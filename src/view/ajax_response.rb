#!/usr/bin/env ruby
# View::AjaxResponse -- davaz.com -- 14.06.2006 -- mhuggler@ywesee.com

require 'json'
require 'htmlgrid/component'

module DAVAZ
	module View
		class AjaxResponse < HtmlGrid::Component
			def to_html(context)
				@model.to_json
			end
		end
	end
end
