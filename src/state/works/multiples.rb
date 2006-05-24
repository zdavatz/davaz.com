#!/usr/bin/env ruby
# State::Works::Multiples -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/works/multiples'

module DAVAZ
	module State
		module Works
class Multiples < State::Works::Global
	VIEW = View::Works::Multiples
	def init
		super
		artobject_id = @session.user_input(:artobject_id) 
		if(artobject_id.nil?)
			multiples = @session.app.load_multiples
			artobject_id = multiples.first.artobject_id
		end
		@model = @session.app.load_artobject(artobject_id)
	end
end
		end
	end
end
