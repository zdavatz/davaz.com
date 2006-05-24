#!/usr/bin/env ruby
# View::ToolTip::ToolTip -- davaz.com -- 04.10.2005 -- mhuggler@ywesee.com

require 'htmlgrid/divtemplate'
require 'htmlgrid/divcomposite'
require 'htmlgrid/div'

module DAVAZ
	module View
		module ToolTip
class ToolTip < HtmlGrid::DivComposite
	CSS_ID = 'tooltip-container'
	HTTP_HEADERS = {
		"Content-Type"	=>	"text/html; charset=UTF-8",
	}			
end
		end
	end
end
