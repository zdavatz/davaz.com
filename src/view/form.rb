#!/usr/bin/env ruby
# View::Form -- davaz.com -- 14.09.2005 -- mhuggler@ywesee.com

require 'htmlgrid/form'

module DAVAZ
	module View
		class Form < HtmlGrid::Form
			LEGACY_INTERFACE = false
		end
	end
end
