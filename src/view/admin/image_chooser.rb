#!/usr/bin/env ruby
# View::Admin::ImageChooser -- davaz.com -- 12.06.2006 -- mhuggler@ywesee.com

require 'htmlgrid/divlist'
require 'htmlgrid/divcomposite'
require 'htmlgrid/inputfile'
require 'view/publictemplate'
require 'view/form'

module DAVAZ
	module View
		module Admin
class LinkImages < HtmlGrid::DivList
	CSS_CLASS = 'image-chooser-link-images'
	COMPONENTS = {
		[0,0]	=>	:image,
		[1,0]	=>	'br',
		[2,0]	=>	:remove_image,
	}
	CSS_MAP = {
		1	=>	'links-list-remove-image'
	}
	def image(model)
		image = HtmlGrid::Image.new(model, @model, @session, self)
		url = DAVAZ::Util::ImageHelper.image_url(model, 'small')
		image.set_attribute('src', url)
		image.set_attribute('width', '100px')
		image.set_attribute('height', '100px')
		image
	end
	def remove_image(model)
		args = [
			[ :link_id, @session.user_input(:link_id) ],
			[ :artobject_id, model ],
		]
		url = @lookandfeel.event_url(:admin, :ajax_remove_image, args) 
		link = HtmlGrid::Link.new(:remove_image, model, @session , self)
		link.href = "javascript:void(0)"
		script = "removeImage('#{url}');"
		link.set_attribute('onclick', script)
		link
	end
end
class ImageChooserList < HtmlGrid::DivList
	COMPONENTS = {
		[0,0]	=>	:image,
	}
	CSS_MAP = {
		0	=>	'image-chooser-image',
	}
	def image(model)
		link = HtmlGrid::Link.new(model.artobject_id.to_s, @model, \
			@session, self)
		image = HtmlGrid::Image.new(model.artobject_id.to_s, @model, \
			@session, self)
		url = DAVAZ::Util::ImageHelper.image_url(model.artobject_id, 'small')
		image.set_attribute('src', url)
		#image.set_attribute('width', '100px')
		#image.set_attribute('height', '100px')
		args = [
			[ :link_id, @session.user_input(:link_id) ],
			[ :artobject_id, model.artobject_id ],
		]
		url = @lookandfeel.event_url(:admin, :ajax_add_image, args) 
		link.href = "javascript:void(0)"
		script = "addImage('#{url}');"
		link.set_attribute('onclick', script)
		link.value = image
		link
	end
end
class UploadForm < View::Form
	EVENT = :upload_image
	LABELS = true
	TAG_METHOD = :multipart_form
	COMPONENTS = {
		[0,0]	=>	:image_file,
		[0,1]	=>	:image_title,
		[0,2]	=>	:submit,
	}
	SYMBOL_MAP = {
		:image_file		=> HtmlGrid::InputFile,
		:image_title	=> HtmlGrid::InputText,
	}
	def hidden_fields(context)
		super <<
		context.hidden('link_id', @model.link_id)
	end
end
class ImageChooserComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		#[0,0]	=>	:back,
		#[0,1]	=>	'image_chooser_link_images_title',
		#[0,2]	=>	component(LinkImages, :displayelements),
		[0,3]	=>	'image_chooser_uploadtitle',
		[0,4]	=>	UploadForm,
		[0,5]	=>	'image_chooser_title',
		#[0,6]	=>	component(ImageChooserList, :display_images),
	}
	CSS_MAP = {
		1	=>	'image-chooser-title',
		3	=>	'image-chooser-title',
		5	=>	'image-chooser-title',
	}
  CSS_ID_MAP = {
    2 => 'links_list_container',
    4 => 'image_upload_form',
  }
	def back(model)
		link = HtmlGrid::Link.new(:back, model, @session, self)
		state = @session.active_state
		link.href = state.request_path
		link
	end
end
class ImageChooserContainerComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=> ImageChooserComposite,	
	}
  CSS_ID_MAP = {
    0 => 'image_chooser_container',
  }
end
class ImageChooser < AdminPublicTemplate
	CONTENT = ImageChooserContainerComposite
end
		end
	end
end
