#!/usr/bin/env ruby
# State::ToolTip::Global -- davaz.com -- 15.03.2006 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'state/global'

module DAVAZ
	module State
		module ToolTip
class Global < State::Global
	VOLATILE = true
	HOME_STATE = State::Personal::Init
	ZONE = :tooltip
end
		end
	end
end
