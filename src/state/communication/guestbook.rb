#!/usr/bin/env ruby
# State::Communication::Guestbook -- davaz.com -- 12.09.2005 -- mhuggler@ywesee.com

require 'sbsm/cgi'
require 'state/global_predefine'
require 'view/ajax_response'
require 'view/communication/guestbook'
require 'view/communication/guestbook_entry'

module DAVAZ
	module State
		module Communication
class AjaxGuestbookEntry < SBSM::State
	VIEW = View::Communication::GuestbookEntryForm
	VOLATILE = true
end
class AjaxSubmitStatus < SBSM::State
	VIEW = View::AjaxResponse
	VOLATILE = true
	def init
		mandatory = [:name, :messagetxt]
    keys = mandatory + [:surname, :email, :city, :country]
		hash = user_input(mandatory, mandatory)
		hash[:name] = "#{hash[:name]} #{hash[:surname]}"
		hash.delete(:surname)
		@model = {}
		messages = []
		if(error?)
			@model[:success] = false
			@errors.each { |key, value|
				messages.push(@session.lookandfeel.lookup(value.message))
			}
			@model[:messages] = messages.join("<br />")
		else
			hash.each { |key, value|
				hash[key] = value
			}
			@session.app.insert_guest(hash)
			@model[:success] = true 
		end
	end
end
class Guestbook < State::Communication::Global
	VIEW = View::Communication::Guestbook
	def init
		@model = @session.app.load_guests
	end
	def ajax_guestbookentry
		AjaxGuestbookEntry.new(@session, @model)
	end
	def submit_entry
		AjaxSubmitStatus.new(@session, @model)
	end
end
class AdminGuestbook < State::Communication::Guestbook
	VIEW = View::Communication::AdminGuestbook
end
		end
	end
end
