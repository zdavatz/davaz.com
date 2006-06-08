#!/usr/bin/env ruby
# View::Gallery::Result -- davaz.com -- 06.06.2006 -- mhuggler@ywesee.com

require 'htmlgrid/divlist'
require 'htmlgrid/divform'
require 'view/publictemplate'
require 'view/list'
require 'view/navigation'

module DAVAZ
	module View
		module Gallery
class ResultList < View::List
	CSS_CLASS = 'result-list'
	STRIPED_BG = true 
	SORT_DEFAULT = :title
	SORT_REVERSE = true
	COMPONENTS = {
		[0,0]	=>	:title,
		[1,0]	=>	:year,
		[2,0]	=>	:tool,
		[3,0]	=>	:material,
		[4,0]	=>	:size,
		[5,0]	=>	:country,
		[6,0]	=>	:serie,
	}
	CSS_MAP = {
		[0,0]	=>	'result-title',
		[1,0]	=>	'result-year',
		[2,0]	=>	'result-tool',
		[3,0]	=>	'result-material',
		[4,0]	=>	'result-size',
		[5,0]	=>	'result-country',
		[6,0]	=>	'result-serie',
	}
	def title(model)
		link = HtmlGrid::Link.new(:title, @model, @session, self)
		args = [ 
			[ :artobject_id, model.artobject_id ]
		]
		unless((search_query = @session.user_input(:search_query)).nil?)
			args.unshift([ :search_query, search_query])
		end
		unless((artgroup_id = @session.user_input(:artgroup_id)).nil?)
			args.unshift([ :artgroup_id, artgroup_id])
		end
		if((video_url = model.google_video_url).empty?)
			link.href = @lookandfeel.event_url(:gallery, :artobject, args)
		else
			link.href = video_url 
			link.set_attribute('target', '_blank')
		end
		link.value = model.title
		link
	end
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
		[5,0]	=>	'country',
		[6,0]	=>	'serie',
	}
	CSS_MAP = {
		[0,0]	=>	'result-title',
		[1,0]	=>	'result-year',
		[2,0]	=>	'result-tool',
		[3,0]	=>	'result-material',
		[4,0]	=>	'result-size',
		[5,0]	=>	'result-country',
		[6,0]	=>	'result-serie',
	}
end
class InputBar < HtmlGrid::InputText
	def init
		super
		val = @lookandfeel.lookup(@name)
		@attributes.update({
			'id'			=>	"searchbar",
		})
		args = [
			[ @name, '' ],
		]
=begin
		unless((artgroup_id = @session.user_input(:artgroup_id)).nil?)
			args.unshift([ :artgroup_id, artgroup_id])
		end
=end
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
		#[0,0]	=>	:all_entries,
		#[1,0]	=>	'pipe_divider',
		[2,0]	=>	:search_query,
		[3,0]	=>	:submit,
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
		[0,0]	=>	View::GalleryNavigation,
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
end
class Result < View::GalleryPublicTemplate
	CONTENT = View::Gallery::ResultComposite
end
		end
	end
end
