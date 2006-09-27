#!/usr/bin/env ruby
# Selenium::DbManager -- davaz.com -- 27.09.2006 -- mhuggler@ywesee.com

require 'model/artobject'

module DAVAZ
	module Stub 
		class DbManager
			def load_artgroups
				[]
			end
			def load_oneliner(location)
				[]
			end
			def load_series(where, load_artobjects=true)
				[]
			end
		end
	end
end
