#!/usr/bin/env ruby
# State::Public::Exhibitions -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/predefine'
require 'view/public/exhibitions'

module DaVaz
	module State
		module Public 
class Exhibitions < State::Public::Global
	VIEW = View::Public::Exhibitions
	def init
		@model = @session.load_exhibitions 
	end
end
		end
	end
end
