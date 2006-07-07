#!/usr/bin/env ruby
# View::ArtObject -- davaz.com -- 07.06.2006 -- mhuggler@ywesee.com

require 'view/publictemplate'

module DAVAZ
	module View
		class ArtobjectDetails < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]	=>	:serie,
				[0,1]	=>	:tool,
				[0,2]	=>	:material,
				[0,3]	=>	:size,
				[0,4]	=>	:date,
				[0,5]	=>	:location,
				[0,6]	=>	:country,
				[0,7]	=>	:language,
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
				[0,5]	=>	:url,
				[0,6]	=>	:text,
			}
			CSS_ID_MAP = {
				0	=>	'artobject-title',	
				1	=>	'artobject-subtitle-left',	
				2	=>	'artobject-subtitle-right',	
				3	=>	'artobject-image',	
				4	=>	'artobject-details',	
				5	=>	'artobject-google-video-url',	
				6	=>	'artobject-text',	
			}
			def image(model)
				img = HtmlGrid::Image.new(model.artobject_id, model, @session, self)
				url = DAVAZ::Util::ImageHelper.image_path(model.artobject_id)
				img.set_attribute('src', url)
				img.css_id = 'artobject-image'
				link = HtmlGrid::HttpLink.new(:url, @model, @session, self)
				link.href = model.url
				link.value = img
				link.set_attribute('target', '_blank')
				if(model.url.empty?)
					img
				else
					link
				end
			end
			def url(model)
				unless((url = model.url).empty?)
					link = HtmlGrid::HttpLink.new(:google_video_link, model, @session, self)
					link.href = url
					link.value = @lookandfeel.lookup(:watch_movie) 
					link.set_attribute('target', '_blank')
					link
				end
			end
		end
		class Pager < HtmlGrid::SpanComposite
			COMPONENTS = {
				[0,0]	=>	:last,
				[0,1]	=>	:items,	
				[0,2]	=>	:next,
			}
			def items(model)
		"Item #{model.artobjects.index(model.artobject)+1} of #{model.artobjects.size}"
			end
			def next(model)
				artobjects = model.artobjects
				active_index = artobjects.index(model.artobject)
				unless(active_index+1 == artobjects.size)
					link = HtmlGrid::Link.new(:paging_next, model, @session, self)
					args = [ 
						[ :artobject_id, artobjects.at(active_index+1).artobject_id ],
					]
					unless((search_query = @session.user_input(:search_query)).nil?)
						args.unshift([ :search_query, search_query])
					end
					unless((artgroup_id = @session.user_input(:artgroup_id)).nil?)
						args.unshift([ :artgroup_id, artgroup_id])
					end
					link.href = @lookandfeel.event_url(:gallery, :art_object, args)
					image = HtmlGrid::Image.new(:paging_next, model, @session, self)
					image_src = @lookandfeel.resource(:paging_next)
					image.set_attribute('src', image_src)
					link.value = image 
					link
				end
			end
			def last(model)
				artobjects = model.artobjects
				active_index = artobjects.index(model.artobject)
				unless(active_index-1 == -1)
					link = HtmlGrid::Link.new(:paging_last, model, @session, self)
					args = [ 
						[ :artobject_id, artobjects.at(active_index-1).artobject_id ],
					]
					unless((search_query = @session.user_input(:search_query)).nil?)
						args.unshift([ :search_query, search_query])
					end
					unless((artgroup_id = @session.user_input(:artgroup_id)).nil?)
						args.unshift([ :artgroup_id, artgroup_id])
					end
					link.href = @lookandfeel.event_url(:gallery, :art_object, args)
					image = HtmlGrid::Image.new(:paging_last, model, @session, self)
					image_src = @lookandfeel.resource(:paging_last)
					image.set_attribute('src', image_src)
					link.value = image 
					link
				end
			end
		end
		class MoviesPager < Pager 
			def pager_link(link)
				artobject_id = link.attributes['href'].split("/").last
				args = [ 
					[ :artobject_id, artobject_id ],
				]
				url = @lookandfeel.event_url(:gallery, :ajax_movie_gallery, args)
				link.href = "javascript:void(0)"
				script = "toggleInnerHTML('movies-gallery-view', '#{url}')"
				link.set_attribute('onclick', script)
				link
			end
			def next(model)
				unless((link = super).nil?)
					link = super
					pager_link(link)
				end
			end
			def last(model)
				unless((link = super).nil?)
					link = super
					pager_link(link)
				end
			end
		end
		class MoviesArtObjectOuterComposite < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]	=>	MoviesPager,
				[0,1]	=>	:back_to_overview,
			}
			CSS_ID_MAP = {
				0	=>	'artobject-pager',
				1	=>	'artobject-back-link',
			}
			def back_to_overview(model)
				link = HtmlGrid::Link.new(:back_to_overview, model, @session, self)
				link.href = "javascript:void(0)" 
				script = "showMovieGallery('movies-gallery-view','movies-list','');"
				link.set_attribute('onclick', script) 
				link
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
		class MoviesArtObjectComposite < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]	=>	MoviesArtObjectOuterComposite,
				[0,1]	=>	component(ArtObjectInnerComposite, :artobject),
			}
			CSS_ID_MAP = {
				0	=>	'artobject-outer-composite',
				1	=>	'artobject-inner-composite',
			}
			HTTP_HEADERS = {
				"type"		=>	"text/html",
				"charset"	=>	"UTF-8",
			}			
		end
		class ArtObjectComposite < HtmlGrid::DivComposite 
			COMPONENTS = {
				[0,0]	=>	ArtObjectOuterComposite,
				[0,1]	=>	component(ArtObjectInnerComposite, :artobject),
			}
			CSS_ID_MAP = {
				0	=>	'artobject-outer-composite',
				1	=>	'artobject-inner-composite',
			}
		end
		class ArtObject < View::GalleryPublicTemplate
			CONTENT = View::ArtObjectComposite
		end
		class AdminArtObject < ArtObject
			def init
				super
				puts "admin view"
			end
		end
	end
end
