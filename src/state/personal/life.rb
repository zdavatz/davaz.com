#!/usr/bin/env ruby
# State::Personal::Life -- davaz.com -- 27.09.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/personal/life'

module DAVAZ
	module State
		module Personal
class Life < State::Personal::Global
	VIEW = View::Personal::Life
	def init
		if(lang = @session.user_input(:lang))
			@model = @session.app.load_biography_text("life_#{lang}") 
		else
			@model = @session.app.load_biography_text("life_english") 
		end
		super
	end
end
		end
	end
end
