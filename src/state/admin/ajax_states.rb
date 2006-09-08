#!/usr/bin/env ruby
# State::Admin::AjaxStates -- davaz.com -- 04.09.2006 -- mhuggler@ywesee.com

require 'state/global'
require 'view/ajax_response'
require 'view/admin/ajax_live_edit_form'
require 'view/textblock'
require 'view/communication/links'

module DAVAZ
	module State
		module Admin
class AjaxCheckRemovalStatus < SBSM::State
	VIEW = View::AjaxResponse
	VOLATILE = true
	def init
		artobject_id = @session.user_input(:artobject_id)
		select_name = @session.user_input(:select_name)
		selected_id = @session.user_input(:selected_id)
		select_class = select_name.split("_").first
		method = "count_#{select_class}_artobjects".intern
		@model = {
			'removalStatus'	=>	'unknown',
		} 
		if(@session.app.respond_to?(method))
			count = @session.app.send(method, selected_id).to_i
			@model['removeLinkId'] = "#{select_class}-remove-link"
			if(count > 1)
				@model['removalStatus'] = "notGoodForRemoval"
			elsif(count == 1)
				method = "load_#{select_class}_artobject_id".intern
				art_id = @session.app.send(method, selected_id)
				if(art_id == artobject_id)
					@model['removalStatus'] = "goodForRemoval"
				else
					@model['removalStatus'] = "notGoodForRemoval"
				end
			else
				@model['removalStatus'] = "goodForRemoval"
				@model['removeLinkId'] = "#{select_class}-remove-link"
			end
		end
	end
end
class AjaxSaveLiveEdit < SBSM::State
	VIEW = View::AjaxResponse
	VOLATILE = true
	def init
		update_value = @session.user_input(:update_value)
		artobject_id = @session.user_input(:artobject_id)
		field_key = @session.user_input(:field_key)
		if(update_value.nil? || update_value.empty?)
			update_value = @session.lookandfeel.lookup(:click2edit)
		end
		update_hash = {
			field_key.intern	=>	update_value,
		}
		@session.app.update_artobject(artobject_id, update_hash)
		artobject = @session.app.load_artobject(artobject_id)
		@model = {
			'updated_value'	=>	artobject.send(field_key.intern),
		} 
	end
end
		end
	end
end
