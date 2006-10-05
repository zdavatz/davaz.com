#!/usr/bin/env ruby
# View::Communication::AjaxViews -- davaz.com -- 12.09.2006 -- mhuggler@ywesee.com

require 'htmlgrid/div'

module DAVAZ 
	module View
		module Admin 
class AjaxAddNewElementComposite < HtmlGrid::DivComposite
	CSS_ID = "add-new-element-composite"
	COMPONENTS = {
		[0,1]	=>	:add_new_element_link,
	}
	CSS_ID_MAP = {
		2	=>	'add-new-element-form'
	}
	def add_new_element_link(model)
		link = HtmlGrid::Link.new(:new_element, model, @session, self)
		link.href = 'javascript:void(0)'
		url = @lookandfeel.event_url(@session.zone, :ajax_add_new_element)
		script = "addNewElement('#{url}')"
		link.set_attribute('onclick', script)
		link
	end
end
class AjaxUploadImageForm < View::Form
	CSS_ID = 'upload-image-form'
	EVENT = :ajax_upload_image
	LABELS = true
	TAG_METHOD = :multipart_form
	FORM_NAME = 'ajax_upload_image_form'
	COMPONENTS = {
		[0,0]	=>	:image_file,
		[1,0]	=>	:submit,
	}
	SYMBOL_MAP = {
		:image_file		=> HtmlGrid::InputFile,
	}
	def hidden_fields(context)
		super <<
		context.hidden('artobject_id', @model.artobject_id)
	end
	def init
		super
		script = <<-EOS 
			return false;	
		EOS
		self.onsubmit = script 
	end
end
class AjaxImageDiv < HtmlGrid::Div
	def image(artobject, url)
		img = HtmlGrid::Image.new('artobject_image', artobject, @session, self)
		img.set_attribute('src', url)
		img.css_id = 'artobject-image'
		link = HtmlGrid::HttpLink.new(:url, artobject, @session, self)
		link.href = artobject.url
		link.value = img
		link.set_attribute('target', '_blank')
		if(artobject.url.empty?)
			@value = img
		else
			@value = link
		end
		img
	end
	def init
		super
		if(artobject_id = @model.artobject_id)
			url = DAVAZ::Util::ImageHelper.image_url(artobject_id)
			image(@model, url)
		elsif(@model.tmp_image_path)
			image(@model, artobject.tmp_image_url)
		end
	end
end
		end
	end
end
