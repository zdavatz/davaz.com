#!/usr/bin/env ruby
# State::ToolTip::ArtObject -- davaz.com -- 10.05.2006 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'state/tooltip/global'
require 'view/tooltip/artobject'

module DAVAZ
	module State
		module ToolTip
class ArtObject < State::ToolTip::Global
	VIEW = View::ToolTip::ArtObject
	def init
		super
		artobject_id = @session.user_input(:artobject_id)
		@model = @session.app.load_artobject(artobject_id)
	end
end
		end
	end
end
