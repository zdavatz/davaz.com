#!/usr/bin/env ruby
# View::FormList -- davaz.com -- 19.09.2005 -- mhuggler@ywesee.com

require 'htmlgrid/formlist'

module DaVaz
	module View
		class FormList < HtmlGrid::FormList 
			LEGACY_INTERFACE = false
		end
	end
end
