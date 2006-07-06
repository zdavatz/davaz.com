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
		@model = OpenStruct.new
		@model.text = @session.app.load_hiswork_text
		@model.slideshow = @session.app.load_tag_artobjects('Morphopolis')
		@model.oneliner = @session.app.load_oneliner('hiswork')
	end
end
class AdminWork < State::Personal::Work
	VIEW = View::Personal::AdminWork
end
		end
	end
end
