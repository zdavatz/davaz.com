#!/usr/bin/env ruby
# Model::Guest -- davaz.com -- 12.09.2005 -- mhuggler@ywesee.com

module DAVAZ
	module Model
		class Guest
			attr_accessor :guest_id, :firstname, :lastname, :email
			attr_accessor	:date, :text, :city, :country
		end
	end
end
