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
		url = DAVAZ::Util::ImageHelper.image_path(@model.display_id, 'large')
		img.attributes['src']	= url
		img.attributes['width'] = MEDIUM_IMAGE_WIDTH 
		#img.attributes['height'] = '150px'
		@value = img
	end
end
class MovieComment < HtmlGrid::Div
	def init
		super
		comment = @model.comment.gsub(/\n/, "[[>>]]")
		comment_arr = comment.split(" ")
		comment = comment_arr.slice(0,50).join(" ").gsub(/\[\[>>\]\]/, "\n")
		if(comment.size > 0)
			comment << " ..."
		end
		@value = comment 
	end
end
class MovieDetailsLink < HtmlGrid::Div
	def init
		super
		link = HtmlGrid::Link.new(:more, @model, @session, self)
		args = [
			:artobject_id, @model.artobject_id	
		]
		event_url = @lookandfeel.event_url(:gallery, :view, args)
		link.href = event_url 
		link.value = @lookandfeel.lookup(:more)
		@value = link 
	end
end
class MovieStreamingLink < HtmlGrid::SpanComposite
	COMPONENTS = {
		[0,0]	=>	:small_streaming_link,
		[1,0]	=>	:large_streaming_link,
	}
	def streaming_link(model, size)
		img_resource = "play_#{size}_movie".intern
		img = HtmlGrid::Image.new(img_resource, model, @session, self)
		link = HtmlGrid::Link.new(:movie_stream, model, @session, self)
		link.href = @lookandfeel.stream_url(model.artobject_id, size)
		unless(link.attributes['href'].nil?)
			link.value = img
		end
		link
	end
	def small_streaming_link(model)
		streaming_link(model, 'small')
	end
	def large_streaming_link(model)
		streaming_link(model, 'large')
	end
end
class MovieComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	MovieDetails,
		[0,1]	=>	MovieImage,
		[0,2]	=>	MovieStreamingLink,
		[0,3]	=>	MovieComment,
		[0,4]	=>	MovieDetailsLink,
	}
	CSS_MAP = {
		0	=>	'movies-details',
		1	=>	'movies-image',
		2	=>	'movies-streaming-links',
		3	=>	'movies-comment',
		4	=>	'movies-details-link',
	}
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
		[1,0]	=>	MoviesList,
	}
end
class Movies < View::MoviesPublicTemplate
	CONTENT = View::Works::MoviesComposite
end
		end
	end
end
