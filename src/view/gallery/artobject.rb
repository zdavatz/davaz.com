#!/usr/bin/env ruby
# View::Gallery::ArtObject -- davaz.com -- 07.06.2006 -- mhuggler@ywesee.com

require 'view/publictemplate'

module DAVAZ
	module View
		module Gallery
class ArtobjectDetails < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	:serie,
		[0,1]	=>	:tool,
		[0,2]	=>	:material,
		[0,3]	=>	:size,
		[0,4]	=>	:date,
		[0,5]	=>	:location,
		[0,6]	=>	:country,
	}
end
class ArtObjectInnerComposite < HtmlGrid::DivComposite
	CSS_ID = 'artobject-inner-composite'
	COMPONENTS = {
		[0,0]	=>	:title,
		[0,1]	=>	:artgroup,
		[0,2]	=>	:tool,
		[0,3]	=>	:image,
		[0,4]	=>	ArtobjectDetails,
		[0,5]	=>	:comment,
	}
	CSS_ID_MAP = {
		0	=>	'artobject-title',	
		1	=>	'artobject-subtitle-left',	
		2	=>	'artobject-subtitle-right',	
		3	=>	'artobject-image',	
		4	=>	'artobject-details',	
		5	=>	'artobject-comment',	
	}
	def image(model)
		img = HtmlGrid::Image.new(model.display_id, model, @session, self)
		url = DAVAZ::Util::ImageHelper.image_path(model.display_id)
		img.set_attribute('src', url)
		img.css_id = 'artobject-image'
		img 
	end
end
class Pager < HtmlGrid::SpanComposite
	COMPONENTS = {
		[0,0]	=>	:last,
		[0,1]	=>	:items,	
		[0,2]	=>	:next,
	}
	def items(model)
		"Item #{@model.index(@session[:active_object])+1} of #{model.size}"
	end
	def next(model)
		active_index = @model.index(@session[:active_object])
		unless(active_index+1 == @model.size)
			link = HtmlGrid::Link.new(:paging_next, model, @session, self)
			args = [ 
				[ :artobject_id, @model.at(active_index+1).artobject_id ],
			]
			unless((search_query = @session.user_input(:search_query)).nil?)
				args.unshift([ :search_query, search_query])
			end
			unless((artgroup_id = @session.user_input(:artgroup_id)).nil?)
				args.unshift([ :artgroup_id, artgroup_id])
			end
			link.href = @lookandfeel.event_url(:gallery, :artobject, args)
			image = HtmlGrid::Image.new(:paging_next, model, @session, self)
			image_src = @lookandfeel.resource(:paging_next)
			image.set_attribute('src', image_src)
			link.value = image 
			link
		end
	end
	def last(model)
		active_index = @model.index(@session[:active_object])
		unless(active_index-1 == -1)
			link = HtmlGrid::Link.new(:paging_last, model, @session, self)
			args = [ 
				[ :artobject_id, @model.at(active_index-1).artobject_id ],
			]
			unless((search_query = @session.user_input(:search_query)).nil?)
				args.unshift([ :search_query, search_query])
			end
			unless((artgroup_id = @session.user_input(:artgroup_id)).nil?)
				args.unshift([ :artgroup_id, artgroup_id])
			end
			link.href = @lookandfeel.event_url(:gallery, :artobject, args)
			image = HtmlGrid::Image.new(:paging_last, model, @session, self)
			image_src = @lookandfeel.resource(:paging_last)
			image.set_attribute('src', image_src)
			link.value = image 
			link
		end
	end
end
class ArtObjectOuterComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	Pager,
		[0,1]	=>	:back_to_overview,
	}
	CSS_ID_MAP = {
		0	=>	'artobject-pager',
		1	=>	'artobject-back-link',
	}
	def back_to_overview(model)
		link = HtmlGrid::Link.new(:back_to_overview, model, @session, self)
		args = []
		unless((search_query = @session.user_input(:search_query)).nil?)
			args.push([ :search_query, search_query])
		end
		unless((artgroup_id = @session.user_input(:artgroup_id)).nil?)
			args.push([ :artgroup_id, artgroup_id])
		end
		link.href = @lookandfeel.event_url(:gallery, :search, args)
		link
	end
end
class ArtObjectComposite < HtmlGrid::DivComposite 
	COMPONENTS = {
		[0,0]	=>	ArtObjectOuterComposite,
		[0,1]	=>	:artobject_inner_composite,
	}
	CSS_ID_MAP = {
		0	=>	'artobject-outer-composite',
		1	=>	'artobject-inner-composite',
	}
	def artobject_inner_composite(model)
		ArtObjectInnerComposite.new(@session[:active_object], @session, self)
	end
end
class ArtObject < View::GalleryPublicTemplate
	CONTENT = View::Gallery::ArtObjectComposite
end
		end
	end
end
