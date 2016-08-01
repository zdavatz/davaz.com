#!/usr/bin/env ruby
# View::Redirect -- davaz.com -- 04.09.2006 -- mhuggler@ywesee.com

require 'htmlgrid/component'

module DaVaz
	module View
		class Redirect < HtmlGrid::Component
			def http_headers
				{
					'Status'		=>	'303 See Other',
					'Location'	=>	@model,
				}
			end
		end
	end
end
