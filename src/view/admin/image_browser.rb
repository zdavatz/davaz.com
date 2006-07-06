#!/usr/bin/env ruby
# View::Admin::ImageBrowser -- davaz.com -- 22.06.2006 -- mhuggler@ywesee.com

require 'htmlgrid/divlist'
require 'htmlgrid/divcomposite'
require 'view/publictemplate'
require 'view/form'

module DAVAZ
	module View
		module Admin
class ImageBrowserList < HtmlGrid::DivList
	COMPONENTS = {
		[0,0]	=>	:image,
	}
	CSS_MAP = {
		0	=>	'image-chooser-image',
	}
	def image(model)
		link_id = @container.model.link.link_id
		link = HtmlGrid::Link.new(model.artobject_id.to_s, @model, \
			@session, self)
		image = HtmlGrid::Image.new(model.artobject_id.to_s, @model, \
			@session, self)
		url = DAVAZ::Util::ImageHelper.image_path(model.artobject_id, 'small')
		image.set_attribute('src', url)
		image.set_attribute('width', '100px')
		image.set_attribute('height', '100px')
		args = [
			[	:artobject_id, model.artobject_id ],
			[	:link_id, link_id ],
		]
		url = @lookandfeel.event_url(:admin, :ajax_add_element, args) 
		#link.href = "javascript:void(0)"
		link.href = "javascript:void(0)"
		script = "toggleInnerHTML('link-composite-#{link_id}', '#{url}');"
		link.set_attribute('onclick', script)
		link.value = image
		link
	end
end
class ImageTags < HtmlGrid::SpanList
	CSS_CLASS = 'image-tags'
	COMPONENTS = {
		[0,0]	=> :tag
	}
	def tag(model)
		link = HtmlGrid::Link.new(model, model, @session, self)
		link.href = "javascript:void(0)"
		link.value = model
		args = [
			[	:link_id, @session.user_input(:link_id) ],
			[ :tags, model ],
		]
		url = @lookandfeel.event_url(:admin, :ajax_reload_tag_images, args)
		script = "toggleInnerHTML('image-browser-container', '#{url}')"
		link.set_attribute('onclick', script)
		link
	end
end
class ImageBrowserComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	'image_chooser_title',
		[0,1]	=>	component(ImageBrowserList, :display_images),
	}
	CSS_MAP = {
		0	=>	'image-chooser-title',
	}
end
class ImageBrowser < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=> component(ImageTags, :image_tags),
		[0,1]	=> ImageBrowserComposite,	
	}
	CSS_ID_MAP = {
		0	=>	'image-browser-tags',
		1	=>	'image-browser-container',
	}
end
		end
	end
end
