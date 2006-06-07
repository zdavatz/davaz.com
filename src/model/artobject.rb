#!/usr/bin/env ruby
# Model::ArtObject -- davaz.com -- 03.10.2005 -- mhuggler@ywesee.com

module DAVAZ
	module Model
		class ArtObject
			attr_accessor :artobject_id, :tool_id, :tool, :material_id, :material
			attr_accessor :artgroup_id, :artgroup, :country_id, :type
			attr_accessor :serie_id, :serie_nr, :serie, :size, :location
			attr_accessor :language, :title, :comment, :public
			attr_accessor :date
			attr_accessor :display_id, :text
			attr_accessor :price, :dollar_price, :euro_price, :count
			attr_reader	:count
		end
	end
end
