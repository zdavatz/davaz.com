#!/usr/bin/env ruby
# View::Gallery::Home -- davaz.com -- 28.09.2005 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/divcomposite'
require 'htmlgrid/spanlist'
require 'view/slideshowrack'

module DAVAZ
	module View
		module Gallery 
class SearchTitle < HtmlGrid::Div
	CSS_CLASS = 'table-title center'
	def init
		super
		img = HtmlGrid::Image.new(:gallery_search_title, model, @session, self)
		@value = img 
	end
end
class SeriesTitle < HtmlGrid::Div
	CSS_CLASS = 'table-title center'
	def init
		super
		img = HtmlGrid::Image.new(:series_title, model, @session, self)
		@value = img 
	end
end
class InputBar < HtmlGrid::InputText
	def init
		super
		val = @lookandfeel.lookup(@name)
		@attributes.update({
			'id'			=>	"searchbar",
		})
		args = [@name, '']
		submit = @lookandfeel.event_url(:gallery, :search, args)
		script = "if(#{@name}.value!='#{val}'){"
		script << "var href = '#{submit}'"
		script << "+escape(#{@name}.value.replace(/\\//, '%2F'));"
		script << "document.location.href=href; } return false"
		self.onsubmit = script
	end
end
class SearchBar < HtmlGrid::Form
	CSS_CLASS = 'center'
	COMPONENTS = {
		[0,0]	=>	:search_query,
		[0,1]	=>	:submit,
		[1,1]	=>	:search_reset,
	}
	COLSPAN_MAP = {
		[0,0]	=>	2,
	}
	SYMBOL_MAP = {
		:search_query			=>	InputBar,	
	}
	EVENT = :search
	FORM_METHOD = 'POST'
	def init
		self.onload = "document.getElementById('searchbar').focus();"
		super
	end
	def search_reset(model, session)
		button = HtmlGrid::Button.new(:search_reset, model, session, self)
		button.set_attribute("type", "reset")
		button
	end
end
class SerieLinks < HtmlGrid::SpanList
	COMPONENTS = {
		[0,0]	=>	:serie_link,
	}
	def serie_link(model)
		link = HtmlGrid::Link.new('toggle-slideshow-rack', model, @session, self)
		link.href = 'javascript:void(0)'
		args = [ :serie_id, model.serie_id ]
		url = @lookandfeel.event_url(:gallery, :ajax_home, args)
		link.value = model.name + @lookandfeel.lookup('comma_divider')
		script = "toggleSearchSlideShowRack(this, '#{url}')"
		link.set_attribute('onclick', script)
		link.css_class = 'serie-link'
		link
	end
end
class UpperHomeComposite < HtmlGrid::DivComposite
	CSS_ID = 'upper-search-composite'
	COMPONENTS = {
		[0,0]	=>	SearchTitle,
		[0,1]	=>	View::GalleryNavigation,
		[0,2]	=>	SearchBar,
		[0,3]	=>	:oneliner,
		[0,4]	=>	SeriesTitle,
	}
	CSS_ID_MAP = {
		0	=>	'search-title',
		2	=>	'search-bar',
		3	=>	'search-oneliner',
	}
	def init
		@artgroups = @session.app.load_artgroups
		super
	end
	def oneliner(model)
		model = @session.app.load_oneliner('index')
		View::Works::OneLiner.new(model, @session, self)		
	end
end
class HomeComposite < HtmlGrid::DivComposite
	CSS_ID = 'inner-content'
	COMPONENTS = {
		[0,0]	=>	UpperHomeComposite,
		[0,1]	=>	:slideshow_rack,
		[0,2]	=>	:serie_links,
	}
	CSS_ID_MAP = {
		0	=>	'upper-search-composite',
		1	=>	'slideshow-rack',
		2	=>	'serie-links',
	}
	def serie_links(model)
		model = @session.app.load_series
		SerieLinks.new(model, @session, self)
	end
	def slideshow_rack(model)
		SearchSlideShowRackComposite.new([], @session, self)
	end
end
class Home < View::GalleryPublicTemplate
	CONTENT = View::Gallery::HomeComposite 
end
		end
	end
end
