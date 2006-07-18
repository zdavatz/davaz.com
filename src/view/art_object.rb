#!/usr/bin/env ruby
# View::ArtObject -- davaz.com -- 07.06.2006 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/form'
require 'view/select'
require 'htmlgrid/divform'
require 'htmlgrid/divlist'
require 'htmlgrid/inputfile'
require 'htmlgrid/errormessage'
require 'RMagick'

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
				[0,2]	=>	:artcode,
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
				script = "toggleInnerHTML('movies-gallery-view', '#{url}', '#{artobject_id}')"
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
		module Breadcrumbs
			def breadcrumbs
				if(bcstring = @session.user_input(:breadcrumbs))
					bcstring.split(',', 2)
				else
					[
						@session.user_input(:artgroup_id),
						@session.user_input(:search_query)
					]
				end
			end
		end
		class ArtObjectOuterComposite < HtmlGrid::DivComposite
			include Breadcrumbs
			COMPONENTS = {
				[0,0]	=>	:pager,
				[0,1]	=>	:back_to_overview,
			}
			CSS_ID_MAP = {
				0	=>	'artobject-pager',
				1	=>	'artobject-back-link',
			}
			def back_to_overview(model)
				return "" if @model.artobjects.empty?
				link = HtmlGrid::Link.new(:back_to_overview, model, @session, self)
				args = [:artgroup_id, :search_query].zip(breadcrumbs())
				link.href = @lookandfeel.event_url(:gallery, :search, args)
				link
			end
			def pager(model)
				unless(@model.artobjects.empty?)
					Pager.new(model, @session, self)
				end
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
		class ShowAllTagsLink < HtmlGrid::Div
			CSS_ID = 'all-tags-link'
			def init
				super
				link = HtmlGrid::Link.new(:show_tags, @model, @session, self)
				link.href = "javascript:void(0)"
				url = @lookandfeel.event_url(:gallery, :ajax_all_tags)
				script = "toggleInnerHTML('all-tags-link', '#{url}')" 
				link.set_attribute('onclick', script)
				@value = link
			end
		end
		class ShowAllTagsList < HtmlGrid::DivList
			COMPONENTS = {
				[0,0]	=>	:tag,
				[1,0]	=>	'pipe_divider',
			}
			def tag(model)
				link = HtmlGrid::Link.new(model.name, model, @session, self)
				link.value = model.name
				link.href = "javascript:void(0)"
				script = <<-EOS
					var values = document.artobjectform.tags_to_s.value.split(',')
					var has_value = false
					for (idx = 0; idx < values.length; idx++) {
						if(values[idx] == '#{model.name}') {
							has_value = true;
						}
					}	
					if(!has_value) {
						values[values.length] = '#{model.name}';
					}
					document.artobjectform.tags_to_s.value = values.join(",");
				EOS
				link.set_attribute('onclick', script)
				link
			end
		end
		class ShowAllTags < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]	=> ShowAllTagsList,
				[0,1]	=> :close,
			}
			CSS_ID_MAP = {
				0	=>	'all-tags',
				1	=>	'close-all-tags',
			}
			def close(model)
				link = HtmlGrid::Link.new(:close, model, @session, self)
				link.href = "javascript:void(0)"
				url = @lookandfeel.event_url(:gallery, :ajax_all_tags_link)
				script = "toggleInnerHTML('all-tags-link', '#{url}')" 
				link.set_attribute('onclick', script)
				link
			end
		end
		class AddFormComposite < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]	=>	:input_field,
				[1,0]	=>	:submit,
				[2,0]	=>	'pipe_divider',
				[3,0]	=>	:cancel,
			}
			def build_script(model)
				name = "#{model.name}_add_form_input"
				args = [ 
					[ :select_name,  model.name ],
					[ :select_value, '' ],
				]
				url = @lookandfeel.event_url(:gallery, :ajax_add_element, args)
				select_id = "#{model.name}_id_select"
				script = "var value = document.artobjectform.#{name}.value;"
				script << "var inputSelect = document.artobjectform.#{select_id};"
				script <<	"addElement(inputSelect, '#{url}', value, '#{model.name}-add-form', '#{model.name}-remove-link');"
				script
			end
			def input_field(model)
				name = "#{model.name}_add_form_input"
				input = HtmlGrid::InputText.new(name, model, @session, self)
				script = "if(event.keyCode == '13') { #{build_script(model)} return false; }"
				input.set_attribute('onkeypress', script)
				input
			end
			def submit(model)
				link = HtmlGrid::Link.new(:submit, model, @session, self)
				link.href = "javascript:void(0)"
				link.set_attribute('onclick', build_script(model))
				link
			end
			def cancel(model)
				name = "#{model.name}_add_form_input"
				link = HtmlGrid::Link.new(:cancel, model, @session, self)
				link.href = "javascript:void(0)"
				script = "toggleInnerHTML('#{model.name}-add-form', 'null')"
				link.set_attribute('onclick', script)
				link
			end
		end
		class EditLinks < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]	=>	:add,
				[1,0]	=>	'pipe_divider',
				[2,0]	=>	:remove,
				[0,1]	=>	:add_form,	
			}
			def init
				css_id_map.store(1, "#{@model.name}-add-form")
				super
			end
			def add(model)
				link = HtmlGrid::Link.new("add_#{model.name}", model, @session, self)
				link.href = "javascript:void(0)"
				args = [
					[ :artobject_id, model.artobject.artobject_id ],
					[ :name, model.name ],
				]
				url = @lookandfeel.event_url(:gallery, :ajax_add_form, args)
				script = "toggleInnerHTML('#{model.name}-add-form', '#{url}')"
				link.set_attribute('onclick', script)
				link
			end
			def remove(model)
				link = HtmlGrid::Link.new("remove_#{model.name}", model, @session, self)
				link.href = "javascript:void(0)"
				args = [
					[ :artobject_id, model.artobject.artobject_id ],
					[ :select_name, model.name ],
					[ :selected_id, '' ],
				]
				url = @lookandfeel.event_url(:gallery, :ajax_remove_element, args)
				link.css_id = "#{model.name}-remove-link"
				script = "var inputSelect = document.artobjectform.#{model.name}_id;"
				script <<	"removeElement(inputSelect, '#{url}', '#{link.css_id}');"
				link.set_attribute('onclick', script)
				link
			end
			def add_form(model)
				""
			end
		end
		class AdminArtobjectDetails < View::Form
			include HtmlGrid::ErrorMessage
			include Breadcrumbs
			def AdminArtobjectDetails.edit_links(*args)
				args.each { |key|
					define_method(key) { |model|
						model.name = key.to_s
						EditLinks.new(model, @session, self)
					}
				}
			end
			CSS_ID = 'artobject-details'
			DEFAULT_CLASS = HtmlGrid::InputText
			EVENT = :update
			FORM_METHOD = 'POST'
			FORM_NAME = 'artobjectform'
			LABELS = true
			COMPONENTS = {
				[0,0]		=>	:title,
				[0,1]		=>	component(View::DynSelect, :select_artgroup, 'artgroup_id'),
				[0,2]		=>	component(View::DynSelect, :select_serie, 'serie_id'),
				[1,3]		=>	:serie,
				[0,4]		=>	:serie_position,
				[0,5]		=>	:tags,
				[1,6]		=>	ShowAllTagsLink,
				[0,7]		=>	component(View::DynSelect, :select_tool, 'tool_id'),
				[1,8]		=>	:tool,
				[0,9]		=>	component(View::DynSelect, :select_material, 'material_id'),
				[1,10]	=>	:material,
				[0,11]	=>	:size,
				[0,12]	=>	:date,
				[0,13]	=>	:location,
				[0,14]	=>	component(View::DynSelect, :select_country, 'country_id'),
				[0,15]	=>	:form_language,
				[0,16]	=>	:url,
				[0,17]	=>	:price,
				[0,19]	=>	:text_label,
				[1,19]	=>	:text,
				[1,20]	=>	:submit,
				[1,20,1]	=>	:reset,
				[1,21]	=>	:delete,
			}	
			edit_links :serie, :tool, :material
			def init
				super
				error_message()
			end
			def hidden_fields(context)
				string = super
				string.concat(context.hidden('breadcrumbs', 
																		 breadcrumbs.join(',')))
			end
			def input_text(symbol, maxlength='50', size='50') 
				input = HtmlGrid::InputText.new(symbol, model, @session, self)
				input.value = model.artobject.send(symbol)
				input.set_attribute('size', size)
				input.set_attribute('maxlength', maxlength)
				input
			end
			def date(model)
				input = HtmlGrid::InputText.new(:date, model, @session, self)
				begin
					year = Date.parse(model.artobject.date).year
					month = Date.parse(model.artobject.date).month
					day = Date.parse(model.artobject.date).day
					input.value = "#{day}.#{month}.#{year}"
				rescue ArgumentError
					input.value = '01.01.1970'
				rescue NoMethodError
					input.value = '00.00.0000'
				end
				input.set_attribute('size', '10')
				input.set_attribute('maxlength', '10')
				input
			end
			def delete(model)
				if(artobject_id = model.artobject.artobject_id)
					button = HtmlGrid::Button.new(:delete, model, @session, self)
					args = [:artgroup_id, :search_query].zip(breadcrumbs())
					args.push(
						[ 'state_id', @session.state.object_id.to_s ]
					)
					url = @lookandfeel.event_url(:admin, :delete, args)
					script = <<-EOS
						var msg = 'Do you really want to delete this artobject?'
						if(confirm(msg)) { 
							window.location.href='#{url}';
						}
					EOS
					button.set_attribute('onclick', script)
					button
				else
					''
				end
			end
			def form_language(model)
				input_text(:language, '150')
			end
			def location(model)
				input_text(:location)
			end
			def price(model)
				input_text(:price, '10')
			end
			def reset(model)
				button = HtmlGrid::Button.new(:reset, model, @session, self)
				button.set_attribute("type", "reset")
				button
			end
			def serie_position(model)
				input_text(:serie_position, '4')
			end
			def size(model)
				input_text(:size)
			end
			def title(model)
				input_text(:title, '150')
			end
			def text_label(model)
				@lookandfeel.lookup(:text)
			end
			def text(model)
				input = HtmlGrid::Textarea.new(:text, model, @session, self)
				input.value = model.artobject.text
				input.set_attribute('cols', '62')
				input.set_attribute('rows', '15')
				input
			end
			def tags(model)
				input_text(:tags_to_s)
			end
			def url(model)
				input_text(:url, '150')
			end
		end
		class UploadForm < View::Form
			CSS_ID = 'upload-image-form'
			EVENT = :ajax_upload_image
			LABELS = true
			TAG_METHOD = :multipart_form
			COMPONENTS = {
				[0,0]	=>	:image_file,
				[1,0]	=>	:submit,
			}
			SYMBOL_MAP = {
				:image_file		=> HtmlGrid::InputFile,
			}
			def hidden_fields(context)
				super <<
				context.hidden('artobject_id', @model.artobject.artobject_id)
			end
			def init
				super
				data_id = 'artobject-admin-image'
				form_id = 'upload-image-form'
				script = "submitForm(this, '#{data_id}', '#{form_id}', true);" 
				script << "return false;"
				self.onsubmit = script 
			end
		end
		class ImageDiv < HtmlGrid::Div
			def image(artobject, url)
				img = HtmlGrid::Image.new('artobject_image', artobject, @session, self)
				img.set_attribute('src', url)
				img.css_id = 'artobject-image'
				link = HtmlGrid::HttpLink.new(:url, artobject, @session, self)
				link.href = artobject.url
				link.value = img
				link.set_attribute('target', '_blank')
				if(artobject.url.empty?)
					@value = img
				else
					@value = link
				end
				img
			end
			def init
				super
				artobject = model.artobject
				if(artobject_id = artobject.artobject_id)
					url = DAVAZ::Util::ImageHelper.image_path(artobject_id)
					image(artobject, url)
				elsif(artobject.abs_tmp_image_path)
					image(artobject, artobject.rel_tmp_image_path)
				end
			end
		end
		class AdminArtObjectInnerComposite < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]	=>	:artcode,
				[0,1]	=>	ImageDiv,
				[0,2]	=>	UploadForm,
				[0,3]	=>	AdminArtobjectDetails,
			}
			CSS_ID_MAP = {
				0	=>	'artobject-title',
				1	=>	'artobject-admin-image',	
				2	=>	'artobject-image-upload-form',	
				3	=>	'artobject-admin-details',	
			}
			SYMBOL_MAP = {
				:artcode =>	HtmlGrid::Value,
			}
			def artcode(model)
				model.artobject.artcode
			end
			def url(model)
				artobject = model.artobject
				unless((url = artobject.url).empty?)
					link = HtmlGrid::HttpLink.new(:google_video_link, artobject, @session, self)
					link.href = url
					link.value = @lookandfeel.lookup(:watch_movie) 
					link.set_attribute('target', '_blank')
					link
				end
			end
		end
		class AdminArtObjectComposite < HtmlGrid::DivComposite 
			COMPONENTS = {
				[0,0]	=>	ArtObjectOuterComposite,
				[0,1]	=>	AdminArtObjectInnerComposite,
			}
			CSS_ID_MAP = {
				0	=>	'artobject-outer-composite',
				1	=>	'artobject-inner-composite',
			}
		end
		class AdminArtObject < View::AdminGalleryPublicTemplate
			CONTENT = View::AdminArtObjectComposite
		end
	end
end
