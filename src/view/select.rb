#!/usr/bin/env ruby
# View::Select -- davaz.com -- 11.07.2006 -- mhuggler@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/select'
require 'htmlgrid/errormessage'

module DAVAZ
	module View
		class DynSelect < HtmlGrid::AbstractSelect
			include HtmlGrid::ErrorMessage
			def init
				super
				error_message()
				args = [ "select_name", @name, "selected_id", nil ]
				url = @lookandfeel.event_url(:gallery, :ajax_check_removal_status, args)
				set_attribute('onchange', "checkRemovalStatus(this.value, '#{url}');")
				set_attribute('id', @name + '_select')
			end
			private
			def selection(context)
				selection = @model.selection.collect { |value|
					val = value.name.to_s
					attributes = { "value" => value.sid }
					attributes.store("selected", true) if(value == @model.selected)
					context.option(attributes) { value.name }
				}
				title = @lookandfeel.lookup(:please_select)
				attrs = { 'value' =>	'' }
				selection.unshift(context.option(attrs) { title } )
			end
		end
=begin
		class DynSelect < HtmlGrid::Composite
			include HtmlGrid::ErrorMessage
			COMPONENTS = {
				[0,0]	=>	DynSelectContent,
			}
			def init
				super
				error_message()
			end
		end
=end
	end
end
