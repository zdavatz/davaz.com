#!/usr/bin/env ruby
# State::Communication::Links -- davaz.com -- 12.09.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/communication/links'

module DAVAZ
	module State
		module Communication
class Links < State::Communication::Global
	VIEW = View::Communication::Links
	def init
		@model = @session.app.load_links
	end
end
class AdminLinks < State::Communication::Links
	VIEW = View::Communication::AdminLinks
end
		end
	end
end
