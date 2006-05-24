#!/usr/bin/env ruby
# State::Communication::Guestbook -- davaz.com -- 12.09.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/communication/guestbook'

module DAVAZ
	module State
		module Communication
class Guestbook < State::Communication::Global
	VIEW = View::Communication::Guestbook
	def init
		@model = @session.app.load_guests
		super
	end
end
		end
	end
end
