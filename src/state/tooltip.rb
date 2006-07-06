#!/usr/bin/env ruby
# State::Tooltip -- davaz.com -- 15.03.2006 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'state/global'
require 'view/tooltip'

module DAVAZ
	module State
		class Tooltip < SBSM::State
			VIEW = View::Tooltip
			VOLATILE = true
			def init
				unless((artobject_id = @session.user_input(:artobject_id)).nil?)
					@model = @session.app.load_artobject(artobject_id)
				else
					title = @session.user_input(:title)
					@model = @session.app.load_artobject(title, 'title')
				end
			end
		end
	end
end
