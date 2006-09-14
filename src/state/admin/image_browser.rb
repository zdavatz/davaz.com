#!/usr/bin/env ruby
# State::Admin::ImageBrowser -- davaz.com -- 12.06.2006 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/admin/image_browser'
require 'util/image_helper'

module DAVAZ
	module State
		module Admin
class AjaxReloadTagImages < SBSM::State
	VIEW = View::Admin::ImageBrowserComposite
	VOLATILE = true
	def init
		user_tags = @session.user_input(:tags)
		if(user_tags.nil? || user_tags.empty?)
			tags = [ 'personal' ]
		else
			tags = user_tags.split(",") 
		end
		@model = OpenStruct.new
		@model.image_tags = @session.app.load_image_tags
		#@model.display_images = @session.app.load_images_by_tags(tags)
	end
end
class AjaxImageBrowser < SBSM::State
	VIEW = View::Admin::ImageBrowser
	VOLATILE = true
	def init
		link_id = @session.user_input(:link_id)
		user_tags = @session.user_input(:tags)
		if(user_tags.nil? || user_tags.empty?)
			tags = [ 'personal' ]
		else
			tags = user_tags.split(",") 
		end
		@model = OpenStruct.new
		@model.image_tags = @session.app.load_image_tags
		@model.display_images = @session.app.load_images_by_tag(tags.first)
	end
end
class ImageBrowser < State::Admin::Global
	VIEW = View::Admin::ImageBrowser
	def init
		link_id = @session.user_input(:link_id)
		@model = OpenStruct.new
=begin
		@model.display_link = @session.app.load_displayelement_link(link_id)
		@model.display_images = @session.app.load_display_images
		@model.displayelements = @model.display_link.displayelements
=end
	end
	def ajax_add_image
		link_id = @session.user_input(:link_id)
		artobject_id = @session.user_input(:artobject_id)
		@session.app.add_image_to_link(link_id, artobject_id)
		#@model = @session.app.load_displayelement_link(link_id)
		#AjaxLinkImages.new(@session, @model.displayelements)
	end
	def ajax_remove_image
		link_id = @session.user_input(:link_id)
		artobject_id = @session.user_input(:artobject_id)
		@session.app.remove_image_from_link(link_id, artobject_id)
		#@model = @session.app.load_displayelement_link(link_id)
		#AjaxLinkImages.new(@session, @model.displayelements)
	end
	def upload_image
		string_io = @session.user_input(:image_file)
		link_id = @session.user_input(:link_id)
		values = {
			:title	=>	@session.user_input(:image_title)
		}
		#insert_id = @session.app.insert_displayelement(values)
		Util::ImageHelper.store_upload_image(string_io, insert_id)
		@session.app.add_image_to_link(link_id, insert_id)
		#@model = @session.app.load_displayelement_link(link_id)
		self
	end
end
		end
	end
end
