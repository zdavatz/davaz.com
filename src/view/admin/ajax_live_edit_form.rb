#!/usr/bin/env ruby
# View::Admin::AjaxLiveEditForm -- davaz.com -- 04.09.2006 -- mhuggler@ywesee.com

require 'htmlgrid/divform'
require 'htmlgrid/input'

module DAVAZ
	module View
		module Admin
class AjaxLiveEditForm < HtmlGrid::DivForm
	#CSS_ID = 'live-edit-form'
	EVENT = :ajax_save_live_edit
	LABELS = false
	COMPONENTS = {
		[0,0]		=>	:edit_field,
		[0,1]		=>	:submit,
		[0,1,1]	=>	:cancel,
	}
	def init
		super
		data_id = 'artobject-admin-image'
		form_id = 'upload-image-form'
		script = "submitForm(this, '#{data_id}', '#{form_id}', true);" 
		script << "return false;"
		self.onsubmit = script 
	end
	def edit_field(model)
		input = HtmlGrid::Input.new(:edit_field, model, @session, self)
		input.value = model.field_value
		input
	end
	def cancel(model)
		button = HtmlGrid::Button.new(:reset, model, @session, self)
		button.set_attribute('value', @lookandfeel.lookup(:cancel))
		node_id = "#{model.artobject_id}-#{model.field_key}"
		args = {
			'artobject_id'	=>	model.artobject_id,
			'field_key'			=>	model.field_key,
		}
		url = @lookandfeel.event_url(:admin, :ajax_cancel_live_edit, args)
		script = "cancelLiveEdit('#{url}', '#{node_id}');" 
		button.set_attribute("onclick", script)
		button
	end
end
		end
	end
end
