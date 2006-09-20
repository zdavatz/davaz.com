#!/usr/bin/env ruby
# Model::ArtObject -- davaz.com -- 03.10.2005 -- mhuggler@ywesee.com

require 'util/image_helper'

module DAVAZ
	module Model
		class ArtObject
			attr_accessor :dollar_price, :euro_price, :count
			attr_accessor :artobject_id
			attr_accessor :tool_id, :tool
			attr_accessor :material_id, :material
			attr_accessor :artgroup_id, :artgroup
			attr_accessor :country_id, :country
			attr_accessor :serie_id, :serie
			attr_accessor :serie_position
			attr_accessor :size, :location
			attr_accessor :language, :title, :public
			attr_accessor :date, :movie_type, :url
			attr_accessor :text, :author, :charset
			attr_accessor :price
			attr_accessor :abs_tmp_image_path
			attr_reader	:links, :tags 
			def initialize
				@links = []
				@tags = []
			end
			def artcode
				begin
					Date.parse(date).year
				rescue ArgumentError
					'0000'
				rescue NoMethodError 
					'0000'
				end
				components = [
					artgroup_id,
					tool_id.rjust(2, "0"),
					material_id.rjust(2, "0"),
					'-',
					country_id.ljust(3, "_"),
					date,
					'-',
					serie_id,
					serie_position.rjust(4, "0"),
				]	
				components.join("")
			end
			def artobject_id
				@artobject_id || nil
			end
			def artgroup_id
				@artgroup_id || ""
			end
			def author
				@author || ""
			end
			def charset
				@charset || ""
			end
			def country_id
				@country_id || ""
			end
			def date
				@date || '00-00-0000'
			end
			def date_ch
				Date.parse(@date).strftime("%d.%m.%Y")	
			end
			def image_string_io
				@image_string_io || nil
			end
			def is_url?
				if(!url.empty? && title.empty? && text.empty?)
					true
				end
			end
			def language
				@language || ""
			end
			def location
				@location || ""
			end
			def material_id
				@material_id || ""
			end
			def movie_type
				@movie_type || ""
			end
			def public
				@public || ""
			end
			def price 
				@price || ""
			end
			def rel_tmp_image_path
				rel = @abs_tmp_image_path.dup
				rel.slice!(DOCUMENT_ROOT)
				rel
			end
			def size
				@size || ""
			end
			def serie_id
				@serie_id || ""
			end
			def serie_position
				@serie_position || ""
			end
			def tags_to_s
				array = tags.collect { |tag| tag.name }
				array.join(',')
			end
			def tags=(tags)
				@tags = tags
			end
			def text
				@text || ""
			end
			def title
				@title || ""
			end
			def tool_id
				@tool_id || ""
			end
			def tool
				@tool || ""
			end
			def url
				@url || ""
			end
		end
	end
end
