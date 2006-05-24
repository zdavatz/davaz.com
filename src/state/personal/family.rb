#!/usr/bin/env ruby
# State::Personal::Family -- davaz.com -- 27.09.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/personal/family'

module DAVAZ
	module State
		module Personal
class Family < State::Personal::Global
	VIEW = View::Personal::Family
end
		end
	end
end

