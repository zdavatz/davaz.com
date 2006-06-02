#!/usr/bin/env ruby
# View::Public::GallerySearch -- davaz.com -- 28.09.2005 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/divcomposite'
require 'view/serielinks'

module DAVAZ
	module View
		module Public
class GallerySearchTitle < HtmlGrid::Div
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
class SearchBar < HtmlGrid::InputText
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
class GallerySearchBar < HtmlGrid::Form
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
		:search_query			=>	SearchBar,	
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
class GallerySearchComposite < HtmlGrid::DivComposite
	CSS_ID = 'inner-content'
	COMPONENTS = {
		[0,0]	=>	GallerySearchTitle,
		#[0,1]	=>	GallerySearchBar,
		[0,2]	=>	:oneliner,
		[0,3]	=>	SeriesTitle,
		[0,4]	=>	:serie_links,
	}
	CSS_ID_MAP = {
		4	=>	'serie-links',
	}
	def oneliner(model)
		model = @session.app.load_oneliner('index')
		View::Works::OneLiner.new(model, @session, self)		
	end
	def serie_links(model)
		model = @session.app.load_series
		View::SerieLinks.new(model, @session, self)
	end
end
class GallerySearch < View::GallerySearchPublicTemplate
	CONTENT = View::Public::GallerySearchComposite 
end
		end
	end
end
