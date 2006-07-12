#!/usr/bin/env ruby
# View::Select -- davaz.com -- 11.07.2006 -- mhuggler@ywesee.com

require 'htmlgrid/divcomposite'
require 'htmlgrid/select'

module DAVAZ
	module View
		class DynSelect < HtmlGrid::AbstractSelect
			def init
				super
				#self.onselect = 'alert("selected");'
			end
			private
			def selection(context)
				@model.selection.collect { |value|
					val = value.name.to_s
					attributes = { "value" => value.sid }
					attributes.store("selected", true) if(value == @model.selected)
					context.option(attributes) { value.name }
				}
			end
		end
	end
end
