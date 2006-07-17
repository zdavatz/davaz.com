#!/usr/bin/env ruby
# State::ArtObject -- davaz.com -- 07.06.2006 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/art_object'

module DAVAZ
	module State
		class AjaxAddElement < SBSM::State
			VOLATILE = true
			def init
				@select_name = @session.user_input(:select_name)
				select_value = @session.user_input(:select_value)
				@session.app.send("add_#@select_name", select_value)
				@model = OpenStruct.new
				@model.selection = @session.app.send("load_#{@select_name}s".intern)
				@model.selection.each { |sel| 
					if(select_value == sel.name)
						@model.selected = sel
					end
				}
			end
			def view
				View::DynSelect.new("#{@select_name}_id", @model, @session, self)
			end
		end
		class AjaxAddForm < SBSM::State
			VIEW = View::AddFormComposite
			VOLATILE = true
			def init
				super
				@model = @session.user_input(:model)
			end
		end
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
		class AjaxRemoveElement < SBSM::State
			VOLATILE = true
=begin
	def init
		select_name = @session.user_input(:select_name)
		selected_id = @session.user_input(:selected_id)
		select_class = select_name.split("_").first
		method = "count_#{select_class}_artobjects".intern
		@model = {
			'removalStatus'	=>	'unknown',
		} 
		if(@session.app.respond_to?(method))
			count = @session.app.send(method, selected_id)
			if(count.to_i > 0)
				@model['removalStatus'] = "notGoodForRemoval"
			else
				@model['removalStatus'] = "goodForRemoval"
				@model['removeLinkId'] = "#{select_class}-remove-link"
			end
		end
	end
=end
			def init
				@select_name = @session.user_input(:select_name)
				selected_id = @session.user_input(:selected_id)
				select_class = @select_name.split("_").first
				method = "count_#{select_class}_artobjects".intern
				if(@session.app.send(method, selected_id).to_i > 0)
					msg = 'e_not_good_for_removal'
					error = create_error(msg, @select_name, selected_id)
					@errors.store(@select_name, error)
					self
				else
					@session.app.send("remove_#@select_name", selected_id)
				end
				@model = OpenStruct.new
				@model.selection = @session.app.send("load_#{@select_name}s".intern)
			end
			def view
				View::DynSelect.new("#{@select_name}_id", @model, @session, self)
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
			def update
				artobject_id = @session.user_input(:artobject_id)
				mandatory = [
					:title,
					:artgroup_id,
					:serie_id,
					:serie_position,
					:tool_id,
					:material_id,
					:date,
					:country_id,
				]
				keys = [
					:tags,
					:location,
					:language,
					:price,
					:size,
					:text,
					:url,
				].concat(mandatory)
				update_hash = user_input(keys, mandatory)
				unless(error?)
					@session.app.update_artobject(artobject_id, update_hash)
					search
				else
					self
				end
			end
		end
	end
end
