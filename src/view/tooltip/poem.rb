#!/usr/bin/env ruby
# View::ToolTip::Poem -- davaz.com -- 15.03.2006 -- mhuggler@ywesee.com

require 'view/tooltip/tooltip'

module DAVAZ
	module View
		module ToolTip
class PoemComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	:title,
		[0,1]	=>	:text,
		[0,2]	=>	:author,
	}
	CSS_MAP = {
		0	=>	'poem-tooltip-title',
		1	=>	'poem-tooltip-text',
		2	=>	'poem-tooltip-author',
	}
end
class Poem < View::ToolTip::ToolTip 
	COMPONENTS = {
		[0,0]	=> PoemComposite,
	}
end
		end
	end
end
