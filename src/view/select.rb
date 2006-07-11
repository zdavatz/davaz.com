#!/usr/bin/env ruby
# View::Select -- davaz.com -- 11.07.2006 -- mhuggler@ywesee.com

require 'htmlgrid/divcomposite'
require 'htmlgrid/select'

module DAVAZ
	module View
		class DynSelect < HtmlGrid::AbstractSelect
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
		class DynSelectComposite < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]	=>	:dyn_select,
				[0,1]	=>	:add,
				[1,1]	=>	:delete,
			}
			def dyn_select(model)
				klass = model.selected.class.to_s.split("::").last.downcase
				DynSelect.new(klass, model, @session, self)
			end
		end
	end
end
