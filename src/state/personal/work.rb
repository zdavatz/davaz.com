#!/usr/bin/env ruby
# State::Personal::Work -- davaz.com -- 27.09.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/personal/work'

module DAVAZ
	module State
		module Personal
class Work < State::Personal::Global
	VIEW = View::Personal::Work
	def init
		@model = @session.app.load_hiswork_text
		super
	end
end
		end
	end
end
