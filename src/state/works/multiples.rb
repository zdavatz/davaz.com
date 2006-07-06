#!/usr/bin/env ruby
# State::Works::Multiples -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/works/multiples'

module DAVAZ
	module State
		module Works
class Multiples < State::Works::RackState
	VIEW = View::Works::Multiples
	def init
		@model = OpenStruct.new
		artobject_id = @session.user_input(:artobject_id) 
		if(artobject_id.nil?)
			multiples = @session.app.load_multiples
			artobject_id = multiples.first.artobject_id
		end
		@model.artobject = @session.app.load_artobject(artobject_id)
		@model.multiples = @session.app.load_multiples()
	end
end
		end
	end
end
