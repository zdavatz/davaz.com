#!/usr/bin/env ruby
# State::ArtObject -- davaz.com -- 07.06.2006 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/art_object'

module DAVAZ
	module State
		class AjaxAllTags < SBSM::State
			VIEW = View::ShowAllTags
			VOLATILE = true
			def init
				@model = @session.app.load_tags
			end
		end
		class AjaxAllTagsLink < SBSM::State
			VIEW = View::ShowAllTagsLink
			VOLATILE = true
			def init
				@model = [] 
			end
		end
		class AjaxUploadImage < SBSM::State
			VIEW = View::ImageDiv
			VOLATILE = true
			def init 
				string_io = @session.user_input(:image_file)
				unless(string_io.nil?)
					artobject_id = @session.user_input(:artobject_id)
					Util::ImageHelper.store_upload_image(string_io, artobject_id)
				end
				model = OpenStruct.new
				model.artobject = @session.app.load_artobject(artobject_id)
			end
		end
		class AjaxMovieGallery < SBSM::State
			VIEW = View::MoviesArtObjectComposite
			VOLATILE = true
			def init
				@model = OpenStruct.new
				artobject_id = @session.user_input(:artobject_id)
				@model.artobjects	= @session.load_movies
				object = @model.artobjects.find { |artobject| 
					artobject.artobject_id == artobject_id
				} 
				@model.artobject = object 
			end
		end
		class ArtObject < State::Global 
			VIEW = View::ArtObject	
			def init
				artobject_id = @session.user_input(:artobject_id)
				artgroup_id = @session.user_input(:artgroup_id)
				query = @session.user_input(:search_query)
				@model = OpenStruct.new
				@model.artobjects = @session.app.search_artobjects(query, artgroup_id)
				object = @model.artobjects.find { |artobject| 
					artobject.artobject_id == artobject_id
				} 
				@model.artobject = object
			end
		end
		class AdminArtObject < ArtObject
			VIEW = View::AdminArtObject
			def build_selection(selected_id, selection)
				select = OpenStruct.new
				select.selection = @session.app.send("load_#{selection}".intern)
				select.selection.each { |sel| 
					if(selected_id == sel.sid)
						select.selected = sel
					end
				}
				select.dup
			end
			def init
				super
				sid = @model.artobject.artgroup_id
				@model.select_artgroup = build_selection(sid, "artgroups")
				sid = @model.artobject.serie_id
				@model.select_serie = build_selection(sid, "series")
				sid = @model.artobject.tool_id
				@model.select_tool = build_selection(sid, "tools")
				sid = @model.artobject.material_id
				@model.select_material = build_selection(sid, "materials")
				sid = @model.artobject.country_id
				@model.select_country = build_selection(sid, "countries")
			end
		end
	end
end
