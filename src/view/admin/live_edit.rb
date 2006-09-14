#!/usr/bin/env ruby
# View::LiveEdit -- davaz.com -- 05.09.2006 -- mhuggler@ywesee.com

require 'htmlgrid/component'
require 'htmlgrid/dojotoolkit'

module DAVAZ
	module View
		module Admin
class LiveEditWidget < HtmlGrid::Div
	def to_html(context)
		url = @lookandfeel.event_url(:admin, :ajax_save_live_edit)
		object_args = {
			:artobject_id => @model.artobject_id,
		} 
		delete_item_url = @lookandfeel.event_url(@session.zone, :ajax_delete_element, object_args)
		delete_image_url = @lookandfeel.event_url(@session.zone, :ajax_delete_image, object_args)
		upload_form_url = @lookandfeel.event_url(@session.zone, :ajax_upload_image_form, object_args)
		args = [
			[ 'update_url', url ],
			[ 'delete_icon_src', @lookandfeel.resource(:icon_cancel) ],
			[ 'delete_icon_txt', @lookandfeel.lookup(:delete) ],
			[ 'delete_image_icon_src', @lookandfeel.resource(:icon_delete) ],
			[ 'delete_image_icon_txt', @lookandfeel.lookup(:delete_image) ],
			[ 'add_image_icon_src', @lookandfeel.resource(:icon_add) ],
			[ 'add_image_icon_txt', @lookandfeel.lookup(:add_image) ],
			[ 'delete_item_url', delete_item_url ],
			[ 'delete_image_url', delete_image_url ],
			[ 'upload_form_url', upload_form_url ]

		]
		if(Util::ImageHelper.has_image?(@model.artobject_id))
			args.push([ 'has_image', 'true' ])
			image_url = Util::ImageHelper.image_path(@model.artobject_id, 'large', true)
			args.push([ 'image_url', image_url ])
		else
			args.push([ 'has_image', 'false' ])
		end
		[
			:artobject_id, :date_ch, :text, :title, :url
		].each { |symbol|
			unless((value = @model.send(symbol)).nil? || value.empty?)	
				args.push([symbol.to_s, value])
			end
		}
		dojo_tag('EditWidget', args)
	end
		end
		end
	end
end
