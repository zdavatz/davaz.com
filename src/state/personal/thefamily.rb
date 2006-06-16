#!/usr/bin/env ruby
# State::Personal::TheFamily -- davaz.com -- 11.10.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/personal/thefamily'

module DAVAZ
	module State
		module Personal
class TheFamily < State::Personal::Global
	VIEW = View::Personal::TheFamily
	def init
		super
		@model = @session.app.load_thefamily_text
	end
end
		end
	end
end
