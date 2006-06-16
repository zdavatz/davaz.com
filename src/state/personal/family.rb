#!/usr/bin/env ruby
# State::Personal::Family -- davaz.com -- 27.09.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/personal/family'

module DAVAZ
	module State
		module Personal
class Family < State::Personal::Global
	VIEW = View::Personal::Family
	def init
		@model = OpenStruct.new
		@model.family_text = @session.app.load_hisfamily_text
		add_slideshow_items(@model, 'family')
	end
end
		end
	end
end
