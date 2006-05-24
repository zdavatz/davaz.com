#!/usr/bin/env ruby
# State::Personal::Inspiration -- davaz.com -- 27.09.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/personal/inspiration'

module DAVAZ
	module State
		module Personal
class Inspiration < State::Personal::Global
	VIEW = View::Personal::Inspiration
end
		end
	end
end
