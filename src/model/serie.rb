#!/usr/bin/env ruby
# Model::Serie -- davaz.com -- 03.10.2005 -- mhuggler@ywesee.com

require 'model/artobject'

module DAVAZ
	module Model
		class Serie
			attr_accessor :serie_id, :name
			attr_reader :artobjects
			alias sid serie_id
			def initialize
				@artobjects = []
			end
		end
	end
end
