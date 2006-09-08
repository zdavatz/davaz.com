#!/usr/bin/env ruby
# View::LiveEdit -- davaz.com -- 05.09.2006 -- mhuggler@ywesee.com

require 'htmlgrid/component'
require 'htmlgrid/dojotoolkit'

module DAVAZ
	module View
		class LiveEdit < HtmlGrid::NamedComponent
			def to_html(context)
				url = @lookandfeel.event_url(:admin, :ajax_save_live_edit)
				args = [
					[ 'artobject_id', @model.artobject_id ],
					[ 'field_key', @name ],
					[ 'old_value', @model.send(@name) ],
					[ 'css_class', "block-#{@name.to_s}" ],
					[ 'update_url', url ],
				]
			end
		end
		class LiveInputText < LiveEdit 
			def to_html(context)
				args = super
				unless(@model.send(@name).empty?)
					dojo_tag('InputText', args)
				else
					""
				end
			end
		end
		class LiveInputTextarea < LiveEdit 
			def to_html(context)
				args = super
				unless(@model.send(@name).empty?)
					dojo_tag('InputTextarea', args)
				else
					""
				end
			end
		end
		class LiveDeleteLink < HtmlGrid::Link 
			def init 
				super
				@href = 'javascript:void(0)'
				@value = @lookandfeel.lookup(:delete)
				@class = 'delete-element'
				args = {
					:artobject_id => @model.artobject_id,
				} 
				url = @lookandfeel.event_url(@session.zone, :ajax_delete_element, args)
				script = <<-EOS 
					var msg = 'Do you really want to delete this Item?'
					if(confirm(msg)) { 
						deleteElement('#{url}')
					}
				EOS
				@attributes['onclick'] = script
			end
		end
	end
end
