#!/usr/bin/env ruby
# Model::Country -- davaz.com -- 10.07.2006 -- mhuggler@ywesee.com

module DAVAZ
	module Model
		class Country
			attr_accessor :country_id, :name
			alias sid country_id
		end
	end
end
