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

module DAVAZ
	module State
		module Admin
module Admin
	VIRAL = true
	EVENT_MAP = {
		:art_object							=>	State::AdminArtObject,
		:articles								=>	State::Public::AdminArticles,
		#:ajax_add_element				=>	State::Admin::AjaxAddElement,
		#:ajax_add_link					=>	State::Admin::AjaxAddLink,
		:ajax_all_tags					=>	State::AjaxAllTags,
		#:ajax_delete_image			=>	State::Admin::AjaxDeleteImage,
		#:ajax_delete_link				=>	State::Admin::AjaxDeleteLink,
		:ajax_image_browser			=>	State::Admin::AjaxImageBrowser,
		:ajax_reload_tag_images	=>	State::Admin::AjaxReloadTagImages,
		#:ajax_remove_element		=>	State::Admin::AjaxRemoveElement,
		:ajax_upload_image			=>	State::AjaxUploadImage,
		#:ajax_upload_image_form	=>	State::Admin::AjaxUploadImageForm,
		:login_form							=>	State::Admin::LoginForm,
		:life										=>	State::Personal::AdminLife,	
		:personal_life					=>	State::Personal::AdminLife,
		:work										=>	State::Personal::AdminWork,
	}
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
	def update
		puts "updating"
		State::AdminArtObject.new(@session, "")
	end
end
		end
	end
end
