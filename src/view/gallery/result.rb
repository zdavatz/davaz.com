#!/usr/bin/env ruby
# View::Gallery::Result -- davaz.com -- 06.06.2006 -- mhuggler@ywesee.com

require 'htmlgrid/divlist'
require 'htmlgrid/divform'
require 'view/publictemplate'
require 'view/list'

module DAVAZ
	module View
		module Gallery
class ResultList < View::List
	CSS_CLASS = 'result-list'
	STRIPED_BG = true 
	SORT_DEFAULT = :title
	COMPONENTS = {
		[0,0]	=>	:title,
		[1,0]	=>	:year,
		[2,0]	=>	:tool,
		[3,0]	=>	:material,
		[4,0]	=>	:size,
		[5,0]	=>	:location,
		[6,0]	=>	:serie,
	}
	CSS_MAP = {
		[0,0]	=>	'result-title',
		[1,0]	=>	'result-year',
		[2,0]	=>	'result-tool',
		[3,0]	=>	'result-material',
		[4,0]	=>	'result-size',
		[5,0]	=>	'result-location',
		[6,0]	=>	'result-serie',
	}
	def year(model)
		begin
			Date.parse(model.date).year
		rescue ArgumentError
			'n.a.'
		end
	end
	def compose_header(offset=[0,0])
		table_title = @model.first.artgroup + " (#{@model.size})"
		@grid.add(table_title, 0, 0)
		@grid.add_tag('TH', 0, 0)
		@grid.set_colspan(0, 0, full_colspan)
		resolve_offset(offset, [0,1])
	end
end
class ResultColumnNames < View::Composite
	CSS_ID = 'result-list-column-names'
	COMPONENTS = {
		[0,0]	=>	'title',
		[1,0]	=>	'year',
		[2,0]	=>	'tool',
		[3,0]	=>	'material',
		[4,0]	=>	'size',
		[5,0]	=>	'location',
		[6,0]	=>	'serie',
	}
	CSS_MAP = {
		[0,0]	=>	'result-title',
		[1,0]	=>	'result-year',
		[2,0]	=>	'result-tool',
		[3,0]	=>	'result-material',
		[4,0]	=>	'result-size',
		[5,0]	=>	'result-location',
		[6,0]	=>	'result-serie',
	}
end
class GalleryNavigation < HtmlGrid::SpanComposite
	CSS_CLASS = 'gallery-navigation'
	COMPONENTS = {
		[0,0]	=>	:gallery,
		[1,0]	=>	'pipe_divider',
	}
	def init
		build_navigation()
		super
	end
	def gallery(model)
		link = HtmlGrid::Link.new(:gallery, model, @session, self)
		args = [
			[ :search_query, @session.user_input(:search_query) ],
		]
		link.href = @lookandfeel.event_url(:gallery, :search, args)
		link.css_class = self::class::CSS_CLASS 
		link
	end
	def build_navigation
		@link_idx = 2
		@model.each_with_index { |event, idx| 
			idx+=1
			pos = [idx*2,0]
			components.store(pos, :navigation_link)
			if(idx > 0 && idx != 7)
				components.store([idx*2-1,0], 'pipe_divider')
			else
				components.store([idx*2-1,0], 'br')
			end
		}
	end
	def navigation_link(model)
		artgroup = @model.at(@link_idx-2).name.downcase
		artgroup_id = @model.at(@link_idx-2).artgroup_id
		@link_idx += 1
		link = HtmlGrid::Link.new(artgroup.intern, model, @session, self)
		args = [
			[ :artgroup_id, artgroup_id ],
			[ :search_query, @session.user_input(:search_query) ],
		]
		link.href = @lookandfeel.event_url(:gallery, :search, args)
		link.css_class = self::class::CSS_CLASS 
		link
	end
end
class SearchBar < HtmlGrid::InputText
	def init
		super
		val = @lookandfeel.lookup(@name)
		@attributes.update({
			'id'			=>	"searchbar",
		})
		args = [
			[ @name, '' ],
		]
		unless((artgroup_id = @session.user_input(:artgroup_id)).nil?)
			args.unshift([ :artgroup_id, artgroup_id])
		end
		submit = @lookandfeel.event_url(:gallery, :search, args)
		script = "if(#{@name}.value!='#{val}'){"
		script << "var href = '#{submit}'"
		script << "+escape(#{@name}.value.replace(/\\//, '%2F'));"
		script << "document.location.href=href; } return false"
		self.onsubmit = script
	end
end
class NewSearch < HtmlGrid::DivForm
	CSS_CLASS = ''
	COMPONENTS = {
		[0,0]	=>	:all_entries,
		[1,0]	=>	'pipe_divider',
		[2,0]	=>	:search_query,
		[3,0]	=>	:submit,
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
	def all_entries(model)
		show_all = :all_entries
		button = HtmlGrid::Button.new(show_all, @model, @session, self)
		args = [ 
			[	:search_query, show_all ],
		]
		unless((artgroup_id = @session.user_input(:artgroup_id)).nil?)
			args.unshift([ :artgroup_id, artgroup_id])
		end
		url = @lookandfeel.event_url(:gallery, :search, args)
		script = "document.location.href='#{url}';"
		button.set_attribute("onclick", script)
		button
	end
end
class ResultComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	:gallery_navigation,
		[0,1]	=>	NewSearch,
		[0,2]	=>	ResultColumnNames,
		[0,3]	=>	:result_list,
	}
	CSS_ID_MAP = {
		0	=>	'gallery-navigation',
		1	=>	'new-search',
	}
	def init
		@artgroups = @session.app.load_artgroups
		super
	end
	def result_list(model)
		tables = []
		@artgroups.each { |artgroup|
			artgroup_items = @model.select { |item|
				item.artgroup_id == artgroup.artgroup_id
			}
			unless(artgroup_items.empty?)
				tables.push(ResultList.new(artgroup_items, @session, self))
			end
		}
		tables	
	end
	def gallery_navigation(model)
		GalleryNavigation.new(@artgroups, @session, self)
	end
end
class Result < View::GalleryPublicTemplate
	CONTENT = View::Gallery::ResultComposite
end
		end
	end
end
