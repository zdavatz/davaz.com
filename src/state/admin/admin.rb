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
require 'view/ajax_response'
require 'sbsm/viralstate'

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
module Admin
	include SBSM::ViralState
	EVENT_MAP = {
		:art_object							=>	State::AdminArtObject,
		#:articles								=>	State::Public::AdminArticles,
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
		:logout									=>	State::Personal::Init,
		#:life										=>	State::Personal::AdminLife,	
		:new_art_object					=>	State::AdminArtObject,
		#:personal_life					=>	State::Personal::AdminLife,
		#:work										=>	State::Personal::AdminWork,
	}
	def ajax_check_removal_status
		AjaxCheckRemovalStatus.new(@session, [])	
	end
	def edit 
		if(!@session.user_input(:artobject_id).nil?)
			#State::Admin::DisplayElementForm.new(@session, self)
		end
	end
	def foot_navigation
		[
			[ :admin, :logout ],
			[ :gallery, :new_art_object ],
			[	:communication, :guestbook ],
			[	:communication, :shop ],
			:email_link,
			[	:communication, :news ],
			[	:communication, :links ],
			[	:personal, :home ],
		]
	end
	def switch_zone(zone)
		infect(super)
	end
end
		end
	end
end
