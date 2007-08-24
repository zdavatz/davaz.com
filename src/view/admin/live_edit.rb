#!/usr/bin/env ruby
# View::LiveEdit -- davaz.com -- 05.09.2006 -- mhuggler@ywesee.com

require 'htmlgrid/component'
require 'htmlgrid/dojotoolkit'

module DAVAZ
	module View
		module Admin
class LiveEditWidget < HtmlGrid::Div
	def compose_element_args
		args = []
		values = []
		args.push([ 'element_id_name', 'artobject_id' ])
		args.push([ 'element_id_value', @model.artobject_id ])
    fields = case @model.serie
             when  /His Life/
               [ :title, :url, :text, ]
             else
               [ :title, :url, :date_ch, :text, ]
             end
		fields.each { |symbol|
			if((value = @model.send(symbol)) && !value.empty?)	
				values.push(symbol.to_s)
				values.push(CGI.escapeHTML(value))
			end
		}
		args.push(['values', values])
		args
	end
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
			image_url = Util::ImageHelper.image_url(@model.artobject_id, nil, true)
			args.push([ 'image_url', image_url ])
		else
			args.push([ 'has_image', 'false' ])
		end
		args.push(['image_pos', 3])
		dojo_tag('EditWidget', args.concat(compose_element_args)).to_html(context)
	end
		end
class GuestbookLiveEditWidget < HtmlGrid::Div 
	def compose_element_args
		args = []
		values = []
		args.push([ 'element_id_name', 'guest_id' ])
		args.push([ 'element_id_value', @model.guest_id ])
		[
			:name, :date_gb, :city, :country, :text
		].each { |symbol| 
			unless((value = @model.send(symbol)).nil? || value.empty?)	
				values.push(symbol.to_s)
				values.push(CGI.escapeHTML(value))
				values.push(@lookandfeel.lookup(symbol))
			end
		}
		args.push(['values', values])
		args	
	end
	def to_html(context)
		url = @lookandfeel.event_url(:admin, :ajax_save_gb_live_edit)
		object_args = {
			:guest_id => @model.guest_id,
		} 
		delete_item_url = @lookandfeel.event_url(@session.zone, :ajax_delete_guest, object_args)
		args = [
			[ 'update_url', url ],
			[ 'delete_item_url', delete_item_url ],
			[ 'delete_icon_src', @lookandfeel.resource(:icon_cancel) ],
			[ 'delete_icon_txt', @lookandfeel.lookup(:delete) ],
			[ 'labels', true ], 
		]
		dojo_tag('EditWidget', args.concat(compose_element_args)).to_html(context)
	end
end
		end
	end
end
