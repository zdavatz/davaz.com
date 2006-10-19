#!/usr/bin/env ruby
# Model::Link -- davaz.com -- 12.09.2005 -- mhuggler@ywesee.com

module DAVAZ
	module Model
		class Link
			attr_accessor :link_id, :word #:block_id, :comment
			attr_accessor :artobject_id
			attr_reader :artobjects
			def initialize
				@artobjects = []
			end
		end
	end
end
