#!/usr/bin/env ruby
# State::Admin::Admin -- davaz.com -- 08.06.2006 -- mhuggler@ywesee.com

require 'state/art_object'
require 'state/public/articles'
require 'state/gallery/result'
require 'state/personal/life'
require 'state/personal/work'
require 'state/admin/login_form'
require 'state/admin/admin_home'
require 'state/admin/image_browser'
require 'src/view/ajax_response'

module DAVAZ
	module State
		module Admin
class AjaxCheckRemovalStatus < SBSM::State
	VIEW = View::AjaxResponse
	VOLATILE = true
	def init
		select_name = @session.user_input(:select_name)
		selected_id = @session.user_input(:selected_id)
		select_class = select_name.split("_").first
		method = "count_#{select_class}_artobjects".intern
		@model = {
			'removalStatus'	=>	'unknown',
		} 
		if(@session.app.respond_to?(method))
			count = @session.app.send(method, selected_id)
			if(count.to_i > 0)
				@model['removalStatus'] = "notGoodForRemoval"
			else
				@model['removalStatus'] = "goodForRemoval"
				@model['removeLinkId'] = "#{select_class}-remove-link"
			end
		end
	end
end
module Admin
	VIRAL = true
	EVENT_MAP = {
		:art_object							=>	State::AdminArtObject,
		:articles								=>	State::Public::AdminArticles,
		#:ajax_add_element				=>	State::Admin::AjaxAddElement,
		:ajax_add_element				=>	State::AjaxAddElement,
		:ajax_add_form					=>	State::AjaxAddForm,
		#:ajax_add_link					=>	State::Admin::AjaxAddLink,
		:ajax_all_tags					=>	State::AjaxAllTags,
		:ajax_all_tags_link			=>	State::AjaxAllTagsLink,
		#:ajax_delete_image			=>	State::Admin::AjaxDeleteImage,
		#:ajax_delete_link				=>	State::Admin::AjaxDeleteLink,
		:ajax_image_browser			=>	State::Admin::AjaxImageBrowser,
		:ajax_reload_tag_images	=>	State::Admin::AjaxReloadTagImages,
		:ajax_remove_element		=>	State::AjaxRemoveElement,
		:ajax_upload_image			=>	State::AjaxUploadImage,
		#:ajax_upload_image_form	=>	State::Admin::AjaxUploadImageForm,
		:login_form							=>	State::Admin::LoginForm,
		:life										=>	State::Personal::AdminLife,	
		:personal_life					=>	State::Personal::AdminLife,
		:work										=>	State::Personal::AdminWork,
	}
	def ajax_check_removal_status
		AjaxCheckRemovalStatus.new(@session, [])	
	end
	def edit 
		if(!@session.user_input(:artobject_id).nil?)
			#State::Admin::DisplayElementForm.new(@session, self)
		end
	end
	def new
		if(@session.user_input(:table) == 'displayelements')
			#State::Admin::DisplayElementForm.new(@session, self)
		end
	end
	def switch_zone(zone)
		infect(super)
	end
end
		end
	end
end
