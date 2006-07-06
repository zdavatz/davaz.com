#!/usr/bin/env ruby
# View::Admin::LinkManager -- davaz.com -- 21.06.2006 -- mhuggler@ywesee.com

require 'htmlgrid/divform'

module DAVAZ
	module View
		module Admin 
class LinkTitle < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	:word,
		[0,1]	=>	:remove_link,
	}
	CSS_MAP = {
		0	=>	'links-list-link-word',
		1	=>	'links-list-remove-link',
	}
	def remove_link(model)
		args = [
			[ :link_id, model.link_id ],
			[ :artobject_id, model.artobject_id ],
		]
		url = @lookandfeel.event_url(:admin, :ajax_delete_link, args) 
		link = HtmlGrid::Link.new(:remove_link, model, @session , self)
		link.href = "javascript:void(0)" 
		script = "toggleInnerHTML('link-manager', '#{url}')"
		link.set_attribute('class', 'links-list-add-image')
		link.set_attribute('onclick', script)
		link
	end
end
class ImageBrowserContainer < HtmlGrid::Div
	def init
		super
		self.send(:css_id=, "image-browser-container-#{model.link_id}")
	end
end
class LinkComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]		=>	LinkTitle,
		[0,1]		=>	:choose_image,
		[1,1]		=>	'pipe_divider',
		[1,1,1]	=>	:add_element,
		[0,2]		=>	ImageBrowserContainer,
	}
	CSS_MAP = {
		0	=>	'links-list-link',
		1	=>	'links-list-add-element',
		3	=>	'links-list-image',
	}
	def choose_image(model)
		args = [
			[	:link_id, model.link_id ],
			[ :tags, @session.user_input(:tags) ],
		]
		url = @lookandfeel.event_url(:admin, :ajax_image_browser, args) 
		link = HtmlGrid::Link.new(:add_element, model, @session , self)
		link.href = 'javascript:void(0)'
		script = "toggleInnerHTML('image-browser-container-#{model.link_id}', '#{url}')"
		link.set_attribute('onclick', script)
		link.value = @lookandfeel.lookup(:choose_image)
		link
	end
	def add_element(model)
		args = [
			[ :parent_link_id, model.link_id ],
			[	:table, 'displayelements' ],
			[ :breadcrumbs, @session.update_breadcrumbs ]
		]
		url = @lookandfeel.event_url(:admin, :new, args) 
		link = HtmlGrid::Link.new(:add_element, model, @session , self)
		link.href = url 
		link
	end
end
class LinksList < HtmlGrid::DivList
	COMPONENTS = {
		[0,0]	=> LinkComposite,
	}
	def tag_attributes(idx)
		hash = super 
		link = @model.at(idx)
		hash.store('id', "link-composite-#{link.link_id}")
		hash
	end
end
class AddLinkForm < HtmlGrid::DivForm
	EVENT = :ajax_add_link
	LABELS = true
	COMPONENTS = {
		[0,0]	=>	:link_word,
		[1,0]	=>	:submit,
	}
	SYMBOL_MAP = {
		:link_word	=>	HtmlGrid::Input,
	}
	def init
		super
		data_id = 'link-manager'
		form_id = 'add-link-form' 
		script = "submitForm(this, '#{data_id}', '#{form_id}', true);" 
		script << "return false;"
		self.onsubmit = script 
	end
	def hidden_fields(context)
		super <<
		#context.hidden('artobject_id', @model.dispelement.artobject_id)
	end
end
class LinkManager < HtmlGrid::DivComposite
	CSS_ID = 'links-list-container' 
	COMPONENTS = {
		[0,0]	=>	AddLinkForm,
		[0,1]	=>	component(LinksList, :links),
	}
	CSS_ID_MAP = {
		0	=>	'add-link-form',
	}
end
		end
	end
end
