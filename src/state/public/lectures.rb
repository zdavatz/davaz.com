#!/usr/bin/env ruby
# State::Public::Lectures -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/predefine'
require 'view/public/lectures'

module DaVaz
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
