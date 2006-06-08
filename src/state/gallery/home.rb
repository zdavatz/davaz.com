#!/usr/bin/env ruby
# State::Gallery::Home -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/gallery/home'

module DAVAZ
	module State
		module Gallery 
class AjaxHome < SBSM::State
	VOLATILE = true
	VIEW = View::SearchSlideShowRackComposite
	def init
		serie_id = @session.user_input(:serie_id)
		@model = @session.load_serie(serie_id)
		super
	end
end
class Home < State::Gallery::Global
	VIEW = View::Gallery::Home
end
		end
	end
end
