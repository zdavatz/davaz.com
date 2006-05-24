#!/usr/bin/env ruby
# State::Communication::GuestbookForm -- davaz.com -- 14.09.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/communication/guestbookentry'

module DAVAZ
	module State
		module Communication
class GuestbookEntry < State::Communication::Global
	VIEW = View::Communication::GuestbookEntry
	def add_entry
		mandatory = [:name, :surname, :email, :city, :country, :messagetxt]
		hash = user_input(mandatory, mandatory)
		unless(error?)
			@session.app.insert_guest(hash)	
			return DAVAZ::State::Communication::Guestbook.new(@session, nil)
		end
		self
	end
end
		end
	end
end
