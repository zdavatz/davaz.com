#!/usr/bin/env ruby
# State::Admin::Admin -- davaz.com -- 08.06.2006 -- mhuggler@ywesee.com

require 'state/art_object'
require 'state/communication/links'
require 'state/communication/news'
require 'state/public/articles'
require 'state/gallery/result'
require 'state/personal/life'
require 'state/personal/work'
require 'state/admin/login'
require 'state/admin/admin_home'
require 'state/admin/image_browser'
require 'state/admin/ajax_states'
require 'sbsm/viralstate'

module DAVAZ
	module State
		module Admin
module Admin
	include SBSM::ViralState
	EVENT_MAP = {
		:art_object							=>	State::AdminArtObject,
		:ajax_all_tags					=>	State::AjaxAllTags,
		:ajax_all_tags_link			=>	State::AjaxAllTagsLink,
		:ajax_delete_element		=>	State::Admin::AjaxDeleteElement,
		:ajax_delete_image			=>	State::Admin::AjaxDeleteImage,
		:ajax_image_browser			=>	State::Admin::AjaxImageBrowser,
		:ajax_reload_tag_images	=>	State::Admin::AjaxReloadTagImages,
		:ajax_remove_element		=>	State::AjaxRemoveElement,
		:ajax_save_live_edit		=>	State::Admin::AjaxSaveLiveEdit,
		:ajax_upload_image			=>	State::Admin::AjaxUploadImage,
		:ajax_upload_image_form	=>	State::Admin::AjaxUploadImageForm,
		:links									=>	State::Communication::AdminLinks,
		:new_art_object					=>	State::AdminArtObject,
		:news										=>	State::Communication::AdminNews,
		:work										=>	State::Personal::AdminWork,
	}
	def ajax_check_removal_status
		State::Admin::AjaxCheckRemovalStatus.new(@session, [])	
	end
	def edit 
		if(!@session.user_input(:artobject_id).nil?)
			#State::Admin::DisplayElementForm.new(@session, self)
		end
	end
	def foot_navigation
		[
			:logout,
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
	def logout
		model = @previous.request_path
		if(fragment = @session.user_input(:fragment))
			model << "##{fragment}" unless fragment.empty?
		end
		State::Redirect.new(@session, model)
	end
end
		end
	end
end
