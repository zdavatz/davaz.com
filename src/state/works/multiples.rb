#!/usr/bin/env ruby
# State::Works::Multiples -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/works/multiples'

module DAVAZ
	module State
		module Works
class AjaxMultiples < SBSM::State
	VIEW = View::Works::JavaApplet
	VOLATILE = true
	def init
		@model = @session.user_input(:artobject_id)
	end
end
class Multiples < State::Works::RackState
	VIEW = View::Works::Multiples
	def init
		@model = OpenStruct.new
		multiples = @session.app.load_multiples
		@model.default_artobject_id = multiples.first.artobject_id
		@model.multiples = @session.app.load_multiples()
	end
end
		end
	end
end
