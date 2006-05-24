#!/usr/bin/env ruby
# View::Composite -- davaz.com -- 28.07.2005 -- mhuggler@ywesee.com

require 'htmlgrid/composite'

module DAVAZ
	module View
		class Composite < HtmlGrid::Composite
			LEGACY_INTERFACE = false
		end
	end
end
