#!/usr/bin/env ruby
# Model::ArtObject -- davaz.com -- 03.10.2005 -- mhuggler@ywesee.com

require 'util/image_helper'

module DAVAZ
	module Model
		class ArtObject
			attr_accessor :artobject_id, :from_artobject_id
			attr_accessor :tool_id, :tool, :material_id
			attr_accessor :material
			attr_accessor :artgroup_id, :artgroup, :country_id, :country
			attr_accessor :serie_id, :serie_position
			attr_accessor :serie, :size, :location
			attr_accessor :language, :title, :public
			attr_accessor :date, :movie_type, :url
			attr_accessor :text, :author, :charset, :position
			attr_accessor :price, :dollar_price, :euro_price, :count
			attr_accessor :linked_to
			attr_reader	:count, :links
			def initialize
				@links = []
			end
			def is_url?
				if(!url.empty? && title.empty? && text.empty?)
					true
				end
			end
		end
	end
end
