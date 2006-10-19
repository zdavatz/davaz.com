#!/usr/bin/env ruby
# State::Gallery::Gallery -- davaz.com -- 31.08.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'state/art_object'
require 'view/gallery/gallery'
require 'view/art_object'
require 'view/rack_art_object'
require 'view/ajax_response'

module DAVAZ
	module State
		module Gallery 
class AjaxAdminDeskArtobject < SBSM::State
	include AdminArtObjectMethods
	VIEW = View::AdminRackArtObjectComposite
	VOLATILE = true
	def init
		@model = OpenStruct.new
		artobject_id = @session.user_input(:artobject_id)
		serie_id = @session.user_input(:serie_id)
		serie	= @session.load_serie(serie_id) 
		@model.artobjects = serie.artobjects
		object = @model.artobjects.find { |artobject| 
			artobject.artobject_id == artobject_id
		} 
		@model.artobject = object 
		@model.fragment = "Desk_#{serie_id}_#{artobject_id}"
		build_selections
	end
end
class AjaxDeskArtobject < SBSM::State
	VIEW = View::RackArtObjectComposite
	VOLATILE = true
	def init
		@model = OpenStruct.new
		artobject_id = @session.user_input(:artobject_id)
		serie_id = @session.user_input(:serie_id)
		serie	= @session.load_serie(serie_id) 
		@model.artobjects = serie.artobjects
		object = @model.artobjects.find { |artobject| 
			artobject.artobject_id == artobject_id
		} 
		@model.artobject = object 
	end
end
class AjaxDesk < SBSM::State
	VIEW = View::Gallery::RackResultListComposite
	VOLATILE = true
	def init
		serie_id = @session.user_input(:serie_id)
		@model = @session.app.load_serie(serie_id).artobjects
	end
end
class AjaxRack < SBSM::State
	VOLATILE = true
	#VIEW = View::SearchSlideShowRackComposite
	VIEW = View::AjaxResponse
	def init
		serie_id = @session.user_input(:serie_id)
		artobject_ids = []	
		images = []	
		titles = []	
		@session.load_serie(serie_id).artobjects.each { |artobject|
			if(Util::ImageHelper.has_image?(artobject.artobject_id))
				image = Util::ImageHelper.image_url(artobject.artobject_id, 'slideshow')
				images.push(image)
				titles.push(artobject.title)
				artobject_ids.push(artobject.artobject_id)
			end
		}
		@model = {
			'artObjectIds'	=>	artobject_ids,
			'images'				=>	images,
			'titles'				=>	titles,
			'imageHeight'		=>	DAVAZ.config.slideshow_image_height,
			'serieId'				=>	serie_id,
		}
		@filter = Proc.new { |model|
			model.store('dataUrl', @request_path)
			model
		}
	end
end
=begin
class AjaxUploadImage < SBSM::State
	include Magick
	VIEW = View::ImageDiv
	VOLATILE = true
	def init 
		@model = OpenStruct.new
		string_io = @session.user_input(:image_file)
		artobject_id = @session.user_input(:artobject_id)
		unless(string_io.nil?)
			if artobject_id
				Util::ImageHelper.store_upload_image(string_io, 
																						 artobject_id)
				@model.artobject = @session.app.load_artobject(artobject_id)
			else
				img_name = Time.now.to_i.to_s 
				image = Image.from_blob(string_io.read).first
				extension = image.format.downcase
				path = File.join(
					DAVAZ::Util::ImageHelper.tmp_image_dir,
					img_name + "." + extension
				)
				image.write(path)
				model = OpenStruct.new
				model.artobject.tmp_image_path = path
			end
		end
	end
end
=end
class Gallery < State::Gallery::Global
	VIEW = View::Gallery::Gallery
	def init
		@model = OpenStruct.new
		@model.oneliner = @session.app.load_oneliner('index')
		@model.series = @session.app.load_series
		@model.artgroups = @session.app.load_artgroups
	end
end
class AdminGallery < State::Gallery::Gallery
	VIEW = View::Gallery::AdminGallery
=begin
	def ajax_upload_image
		AjaxUploadImage.new(@session, @model)
	end
	def delete
		artobject_id = @session.user_input(:artobject_id)
		@session.app.delete_artobject(artobject_id)
		model = @session.lookandfeel.event_url(:gallery, :gallery)
		State::Redirect.new(@session, model)
	end
	def update
		artobject_id = @session.user_input(:artobject_id)
		keys = [
			:title,
			:artgroup_id,
			:serie_id,
			:serie_position,
			:tool_id,
			:material_id,
			:date,
			:country_id,
			:tags_to_s,
			:location,
			:form_language,
			:price,
			:size,
			:text,
			:url,
		]
		update_hash = {}
		user_input(keys, []).each { |key, value|
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
				update_hash.store(key, value)
			end	
		}
		serie_id = nil
		if(update_hash['serie_id'].nil?)
			serie_id = @session.user_input(:old_serie_id)
		else
			serie_id = update_hash['serie_id'] 
		end
		unless(error?)
			if(artobject_id)
				@session.app.update_artobject(artobject_id, update_hash)
				model = @session.lookandfeel.event_url(:gallery, :gallery)
				model << "#DESK_#{serie_id}_#{artobject_id}"
				State::Redirect.new(@session, model)
			else
				insert_id = @session.app.insert_artobject(update_hash)
				image_path = @model.artobject.tmp_image_path
				Util::ImageHelper.store_tmp_image(image_path, insert_id)
				AjaxDeskArtobject.new(@session, [])
			end
		else
			model = @session.lookandfeel.event_url(:gallery, :gallery)
			model << "#DESK_#{serie_id}_#{artobject_id}"
			State::Redirect.new(@session, model)
		end
	end
=end
end
		end
	end
end
