#!/usr/bin/env ruby
# State::Works::Movies -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/works/movies'

module DAVAZ
	module State
		module Works
class Movies < State::Works::Global
	VIEW = View::Works::Movies
	def init
		super
		@model = @session.load_movies()
	end
end
		end
	end
end
