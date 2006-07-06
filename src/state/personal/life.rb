#!/usr/bin/env ruby
# State::Personal::Life -- davaz.com -- 27.09.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/personal/life'

module DAVAZ
	module State
		module Personal
class Life < State::Personal::Global
	VIEW = View::Personal::Life
	DIRECT_EVENT = :life
	def init
		@model = OpenStruct.new
		if(lang = @session.user_input(:lang))
			@model.biography_items = @session.app.load_hislife(lang) 
		else
			@model.biography_items = @session.app.load_hislife('english') 
		end
		add_slideshow_items(@model, 'hislife_show')
		@model.oneliner = @session.app.load_oneliner('hislife')
	end
end
class AdminLife < State::Personal::Life
	VIEW = View::Personal::AdminLife
end
		end
	end
end
