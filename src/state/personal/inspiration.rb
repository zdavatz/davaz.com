#!/usr/bin/env ruby
# State::Personal::Inspiration -- davaz.com -- 27.09.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/personal/inspiration'

module DAVAZ
	module State
		module Personal
class Inspiration < State::Personal::Global
	VIEW = View::Personal::Inspiration
	def init
		super
		@model = OpenStruct.new
		@model.text = @session.app.load_hisinspiration_text
		@model.oneliner = @session.app.load_oneliner('hisinspiration')
	end
end
		end
	end
end
