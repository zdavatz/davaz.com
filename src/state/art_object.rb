#!/usr/bin/env ruby
# State::ArtObject -- davaz.com -- 07.06.2006 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/art_object'
require 'model/artobject'
require 'model/tag'

module DAVAZ
	module State
		module AdminArtObjectMethods
			def build_selection(selection, args)
				artobject_id = args[:aid]	
				selected_id = args[:sid]	
				select = OpenStruct.new
				select.artobject_id = artobject_id
				select.selection = @session.app.send("load_#{selection}".intern)
				select.selection.each { |sel| 
					if(selected_id == sel.sid)
						select.selected = sel
					end
				}
				select.dup
			end
			def build_selections
				args = { :aid => nil, :sid => nil }
				args[:aid] = @model.artobject.artobject_id if @model.artobject
				args[:sid] = @model.artobject.artgroup_id if @model.artobject
				@model.select_artgroup = build_selection("artgroups", args)
				args[:sid] = @model.artobject.serie_id if @model.artobject
				@model.select_serie = build_selection("series", args)
				args[:sid] = @model.artobject.tool_id if @model.artobject
				@model.select_tool = build_selection("tools", args)
				args[:sid] = @model.artobject.material_id if @model.artobject
				@model.select_material = build_selection("materials", args)
				args[:sid] = @model.artobject.country_id if @model.artobject
				@model.select_country = build_selection("countries", args)
			end
		end
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
				View::AjaxDynSelect.new("#{@select_name}_id", @model, @session, self)
			end
		end
		class AjaxAddForm < SBSM::State
			VIEW = View::AddFormComposite
			VOLATILE = true
			def init
				super
				@model = OpenStruct.new
				@model.artobject_id = @session.user_input(:artobject_id)
				@model.name = @session.user_input(:name)
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
		class AjaxRemoveElement < SBSM::State
			VOLATILE = true
			def add_error(select_name, selected_id)
				msg = 'e_not_good_for_removal'
				error = create_error(msg, select_name, selected_id)
				@errors.store("#{@select_name}_id", error)
			end
			def init
				artobject_id = @session.user_input(:artobject_id)
				@select_name = @session.user_input(:select_name)
				selected_id = @session.user_input(:selected_id)
				select_class = @select_name.split("_").first
				method = "count_#{select_class}_artobjects".intern
				count = @session.app.send(method, selected_id).to_i 
				if(count > 1)
					add_error(@select_name, selected_id)
					self
				elsif(count == 1)
					method = "load_#{select_class}_artobject_id".intern
					art_id = @session.send(method, selected_id)
					if(art_id == artobject_id)
						@session.app.send("remove_#@select_name", selected_id)
					else
						add_error(@select_name, selected_id)
					end
				else
					@session.app.send("remove_#@select_name", selected_id)
				end
				@model = OpenStruct.new
				@model.artobject = @session.app.load_artobject(artobject_id)
				selected_id = @model.artobject.send("#{@select_name}_id".intern)
				@model.selection = @session.app.send("load_#{@select_name}s".intern)
				@model.selection.each { |sel| 
					if(selected_id == sel.sid)
						@model.selected = sel
					end
				}
			end
			def view
				View::AjaxDynSelect.new("#{@select_name}_id", @model, @session, self)
			end
		end
		class AjaxUploadImage < SBSM::State
			include Magick
			VIEW = View::ImageDiv
			VOLATILE = true
			def init 
				string_io = @session.user_input(:image_file)
				unless(string_io.nil?)
					artobject_id = @model.artobject.artobject_id 
					if artobject_id
						Util::ImageHelper.store_upload_image(string_io, 
																								 artobject_id)
						model = OpenStruct.new
						model.artobject = @session.app.load_artobject(artobject_id)
					else
						img_name = Time.now.to_i.to_s 
						image = Image.from_blob(string_io.read).first
						extension = image.format.downcase
						path = File.join(
							DAVAZ::Util::ImageHelper.tmp_image_dir,
							img_name + "." + extension
						)
						image.write(path)
						@model.artobject.tmp_image_path = path
					end
				end
			end
		end
		class ArtObject < State::Global 
			VIEW = View::ArtObject	
			def init
				artobject_id = @session.user_input(:artobject_id)
				artgroup_id = @session.user_input(:artgroup_id)
				serie_id = @session.user_input(:serie_id)
				query = @session.user_input(:search_query)
				@model = OpenStruct.new
				if(query)
					@model.artobjects = @session.app.search_artobjects(query, artgroup_id)
				elsif(serie_id)
					@model.artobjects = @session.load_serie(serie_id).artobjects
				elsif(artgroup_id)
					@model.artobjects = @session.load_artgroup_artobjects(artgroup_id)
				else
					@model.artobjects = []
				end
				object = @model.artobjects.find { |artobject| 
					artobject.artobject_id == artobject_id
				} 
				@model.artobject = object
			end
		end
		class AdminArtObject < ArtObject
			include AdminArtObjectMethods
			VIEW = View::AdminArtObject
			def init
				super
				build_selections
				if @model.artobject.nil?
					@model.artobjects = []
					@model.artobject = Model::ArtObject.new
				end
			end
			def ajax_upload_image
				AjaxUploadImage.new(@session, @model)
			end
			def delete
				artobject_id = @model.artobject.artobject_id	
				@session.app.delete_artobject(artobject_id)
				search
			end
			def update
				artobject_id = @model.artobject.artobject_id
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
					:tags_to_s,
					:location,
					:form_language,
					:price,
					:size,
					:text,
					:url,
				].concat(mandatory)
				update_hash = {}
				user_input(keys, mandatory).each { |key, value|
					if(match = key.to_s.match(/(form_)(.*)/))
						update_hash.store(match[2].intern, value)
					elsif(key == :tags_to_s)
						if(value.nil?)
							update_hash.store(:tags, [])	
						else
							update_hash.store(:tags, value.split(','))	
						end
					elsif(key == :date)
						update_hash.store(:date, "#{value.year}-#{value.month}-#{value.day}")
					else
						update_hash.store(key, @session.app.enc2utf8(value))
					end	
				}
				unless(error?)
					if(artobject_id)
						@session.app.update_artobject(artobject_id, update_hash)
					else
						insert_id = @session.app.insert_artobject(update_hash)
						image_path = @model.artobject.tmp_image_path
						Util::ImageHelper.store_tmp_image(image_path, insert_id)
						artobject_id = insert_id
					end
					args = [
						[ :artobject_id, artobject_id ],
					]
					if(search_query = @session.user_input(:search_query))
						args.push([ :search_query, search_query ])
					else
						args.push([ :artgroup_id, @session.user_input(:artgroup_id) ])
					end
					model = @session.lookandfeel.event_url(:gallery, :art_object, args)
					State::Redirect.new(@session, model)
				else
					tags = []
					update_hash.each { |key, value|
						if(key==:tags)
							tag = Model::Tag.new
							tag.name = value
							tags.push(tag)
						end
						puts "key: #{key}, value: #{value}"
						method = (key.to_s + "=").intern
						@model.artobject.send(method, value)
					}
					@model.artobject.send("tags=", tags)
					build_selections
					self
				end
			end
		end
	end
end
