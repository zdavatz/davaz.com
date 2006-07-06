#!/usr/bin/env ruby
# State::Images -- davaz.com -- 27.03.2006 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/images'

module DAVAZ
	module State
		class Images < State::Global
			VIEW = View::Images
			def init
				link_id = @session.user_input(:link_id)
				#@model = @session.app.load_link_displayelements(link_id) 
			end
		end
	end
end
