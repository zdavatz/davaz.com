#!/usr/bin/env ruby
# Selenium::YusServer -- davaz.com -- 03.10.2006 -- mhuggler@ywesee.com

require 'digest/sha2'

module DAVAZ
	module Stub
		class User
			attr_reader :valid
			def allowed?(action, site)
				if(action=='edit' && site =='com.davaz')
					true
				else
					false
				end
			end
			def valid?
				true
			end
		end

		class YusServer
			def login(email, pass, config)
				if(email == 'right@user.ch')
					User.new
				else
					raise Yus::YusError
				end
			end
			def logout(arg)
			end
		end
	end
end
