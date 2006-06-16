#!/usr/bin/env ruby
# State::Personal::Init -- davaz.com -- 18.07.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/personal/init'
require 'model/oneliner'

module DAVAZ
	module State
		module Personal 
class Init < State::Personal::Global
	VIEW = View::Personal::Init
	def init
		super
		@model = OpenStruct.new
		@model.movies = @session.app.load_movies
		@model.oneliner = @session.app.load_oneliner('index')
	end
end
		end
	end
end
