#!/usr/bin/env ruby
# View::Select -- davaz.com -- 11.07.2006 -- mhuggler@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/select'
require 'htmlgrid/errormessage'

module DAVAZ
	module View
		class DynSelect < HtmlGrid::AbstractSelect
			def init
				super
				args = [ 
					[ :artobject_id, @model.artobject_id ],
					[ :select_name, @name ],
					[ :selected_id, nil ] 
				]
				url = @lookandfeel.event_url(:gallery, :ajax_check_removal_status, args)
				script = "checkRemovalStatus(this.value, '#{url}');"
				set_attribute('onchange', script)
				selected_id = if(@model.selected)
					@model.selected.send(@name.intern)
				else
					''
				end
				script = "checkRemovalStatus('#{selected_id}', '#{url}');"
				self.onload = script 
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
		class AjaxDynSelect < DynSelect
			include HtmlGrid::ErrorMessage
			def to_html(context)
				html = super
				if(error = @session.error(@name))
					html << context.br << error_text(error).to_html(context)
				end
				html
			end
		end
	end
end
