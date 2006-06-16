#!/usr/bin/env ruby
# Model::DisplayElement -- davaz.com -- 29.03.2006 -- mhuggler@ywesee.com

require 'model/global'

module DAVAZ
	module Model
		class DisplayElement < Model::Global
			attr_accessor :display_id, :title, :text, :author, :date
			attr_accessor :display_type, :location, :position, :link_id
			attr_accessor :charset, :to_display_id
			attr_reader :links
			def initialize
				@links = []
			end
		end
	end
end
