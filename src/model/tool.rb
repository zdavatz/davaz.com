#!/usr/bin/env ruby
# Model::Tool -- davaz.com -- 10.07.2006 -- mhuggler@ywesee.com

module DAVAZ
	module Model
		class Tool
			attr_accessor :tool_id, :name
			alias sid tool_id
		end
	end
end
