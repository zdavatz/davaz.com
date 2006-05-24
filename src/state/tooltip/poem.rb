#!/usr/bin/env ruby
# State::ToolTip::Poem -- davaz.com -- 15.03.2006 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'state/tooltip/global'
require 'view/tooltip/poem'

module DAVAZ
	module State
		module ToolTip
class Poem < State::ToolTip::Global
	VIEW = View::ToolTip::Poem
	def init
		super
		display_id = @session.user_input(:display_id)
		@model = @session.app.load_poem(display_id)
	end
end
		end
	end
end
