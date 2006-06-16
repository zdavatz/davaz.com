#!/usr/bin/env ruby
# State::Public::Lectures -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/public/lectures'

module DAVAZ
	module State
		module Public 
class Lectures < State::Public::Global
	VIEW = View::Public::Lectures
	def init
		@model = @session.load_lectures
	end
end
		end
	end
end
