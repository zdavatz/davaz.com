#!/usr/bin/env ruby
# View::DivList -- davaz.com -- 05.09.2005 -- mhuggler@ywesee.com

require 'htmlgrid/list'

module DAVAZ
	module View
		class List < HtmlGrid::List
			LEGACY_INTERFACE = false
		end
	end
end
