#!/usr/bin/env ruby
# State::ToolTip::Image -- davaz.com -- 15.03.2006 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'state/tooltip/global'
require 'view/tooltip/image'

module DAVAZ
	module State
		module ToolTip 
class Image < State::ToolTip::Global
	VIEW = View::ToolTip::Image
	def init
		super
		link_id = @session.user_input(:link_id)
		@model = @session.app.load_link_displayelements(link_id)
	end
end
		end
	end
end
