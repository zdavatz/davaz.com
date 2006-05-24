#!/usr/bin/env ruby
# View::ToolTip::Html -- davaz.com -- 08.05.2006 -- mhuggler@ywesee.com

require 'view/tooltip/tooltip'

module DAVAZ
	module View
		module ToolTip
class Html < View::ToolTip::ToolTip
	COMPONENTS = {
		[0,0]	=>	:text,
	}
end
		end
	end
end
