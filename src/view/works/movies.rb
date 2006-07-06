#!/usr/bin/env ruby
# View::Works::Movies -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/composite'
require 'view/list'
require 'htmlgrid/spancomposite'
require 'htmlgrid/value'
require 'htmlgrid/link'
require 'date'
require 'util/image_helper'

module DAVAZ
	module View
		module Works
class MovieDetails < HtmlGrid::SpanComposite
	COMPONENTS = {
		0	=>	:year,
		1	=>	:title,
		2	=>	:size,
		3	=>	:location,
		4	=>	:language,
	}
	CSS_MAP = {
		0	=>	'movies-details',
		1	=>	'movies-details movies-title',
		2	=>	'movies-details',
		3	=>	'movies-details',
		4	=>	'movies-details',
	}
	def year(model) 
		Date.parse(model.date).year	
	end
end
class MovieImage < HtmlGrid::Div
	def init
		super
		img = HtmlGrid::Image.new(:movie_image, @model, @session, self) 
		url = DAVAZ::Util::ImageHelper.image_path(@model.artobject_id, 'large')
		img.attributes['src']	= url
		img.attributes['width'] = MEDIUM_IMAGE_WIDTH 
		#img.attributes['height'] = '150px'
		link = HtmlGrid::HttpLink.new(:url, @model, @session, self)
		link.href = @model.url
		link.set_attribute('target', '_blank')
		link.value = img
		if(@model.url.empty?)
			@value = img
		else
			@value = link
		end
	end
end
class MovieComment < HtmlGrid::Div
	def init
		super
		comment = @model.text.gsub(/\n/, "[[>>]]")
		comment_arr = comment.split(" ")
		comment = comment_arr.slice(0,50).join(" ").gsub(/\[\[>>\]\]/, "\n")
		if(comment.size > 0)
			comment << " ..."
		end
		@value = comment 
	end
end
class GoogleVideoLink < HtmlGrid::Div
	def init
		super
		link = HtmlGrid::HttpLink.new(:url, @model, @session, self)
		link.href = @model.url
		link.value = @lookandfeel.lookup(:watch_movie)
		unless(@model.url.empty?)
			@value = link 
		end
	end
end
class MoreLink < HtmlGrid::Div
	def init
		super
		link = HtmlGrid::Link.new(:more, @model, @session, self)
		args = [
			:artobject_id, @model.artobject_id	
		]
		url = @lookandfeel.event_url(:gallery, :ajax_movie_gallery, args)
		link.href = "javascript:void(0)" 
		link.value = @lookandfeel.lookup(:more)
		replace_id = "movies-list"
		div_id = "movies-gallery-view"
		script = "showMovieGallery('#{div_id}', '#{replace_id}', '#{url}')"
		link.set_attribute('onclick', script)
		@value = link 
	end
end
class MovieComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	MovieDetails,
		[0,1]	=>	MovieImage,
		[0,2]	=>	GoogleVideoLink,
		[0,3]	=>	MovieComment,
		[0,4]	=>	MoreLink,
	}
	CSS_MAP = {
		0	=>	'movies-details',
		1	=>	'movies-image',
		2	=>	'movies-google-link',
		3	=>	'movies-comment',
		4	=>	'movies-details-link',
	}
	def movie_details_div(model)
		""
	end
	def init
		css_id_map.store(4, "movie-details-link-#{@model.artobject_id}")
		css_id_map.store(5, "movie-details-div-#{@model.artobject_id}")
		super
	end
end
class MoviesList < HtmlGrid::DivList 
	COMPONENTS = {
		[0,0]	=>	MovieComposite,
	}
	CSS_MAP = {
		0	=>	'movies-list-item',
	}
end
class MoviesTitle < HtmlGrid::Div
	CSS_CLASS = 'table-title'
	def init
		super
		span = HtmlGrid::Span.new(model, @session, self)
		span.css_class = 'table-title'
		span.value = @lookandfeel.lookup(:movies)
		@value = span
	end
end
class MoviesComposite < HtmlGrid::DivComposite
	CSS_CLASS = 'content'
	COMPONENTS = {
		[0,0]	=>	MoviesTitle,
		[0,1]	=>	MoviesList,
		[0,2]	=>	:movies_gallery_view,
	}
	CSS_ID_MAP = {
		1	=>	'movies-list',
		2	=>	'movies-gallery-view',
	}
	CSS_STYLE_MAP = {
		2	=>	'display:none;',
	}
end
class Movies < View::MoviesPublicTemplate
	CONTENT = View::Works::MoviesComposite
end
		end
	end
end
