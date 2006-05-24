#!/usr/bin/env ruby
# Model::Link -- davaz.com -- 12.09.2005 -- mhuggler@ywesee.com

module DAVAZ
	module Model
		class Link
			attr_accessor :link_id, :block_id, :word, :comment
			attr_accessor :href, :type
			attr_reader :displayelements
			def initialize
				@displayelements = []
			end
			def add_displayelement(displayelement)
				@displayelements.push(displayelement)
			end
		end
	end
end
