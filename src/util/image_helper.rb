#!/usr/bin/env ruby
# ImageProcessor -- davaz.com -- 31.05.2006 -- mhuggler@ywesee.com

require 'RMagick'

module DAVAZ
	module Util 
		class ImageHelper
			include Magick	
			UPLOAD_IMAGES_PATH = 'uploads/images'
			def initialize
				@original_images = ImageList.new
				@processed_images = {
					:medium =>	ImageList.new,
					:large	=>	ImageList.new,
					:slideshow	=>	ImageList.new,
				}
				@geometries = {
					:medium =>	Geometry.new(MEDIUM_IMAGE_WIDTH.to_i),
					:large	=>	Geometry.new(LARGE_IMAGE_WIDTH.to_i),
					:slideshow	=>	Geometry.new(nil, SLIDESHOW_IMAGE_HEIGHT.to_i),
				}
			end
			def add_processed_image(size, img)
				@processed_images[size].push(img)
			end
			def add_image(display_id)
				name = ImageHelper.abs_upload_image(display_id)
				original = Image.read(name).first
				resize_image(display_id, original)
			end
			def resize_image(display_id, image)
				@geometries.each { |key, value| 
					image.change_geometry(value) { |cols, rows, img|
						store_image(display_id, img.resize(cols, rows), key)
					}	
				}
			end
			def store_image(display_id, image, key)
				path = ImageHelper.images_path(key.to_s)
				directory = display_id[-1,1]
				name = [
					path,
					directory,
					"#{display_id}.#{image.format.downcase}",
				].join("/") 
				image.write(name)
			end

			#class Methods

			def ImageHelper.images_path(size)
				dir_components = [
					DOCUMENT_ROOT,
					"resources",
					UPLOAD_IMAGES_PATH,
				]
				dir_components.push(size) unless size.nil?
				dir_components.join("/")
			end
			def ImageHelper.image_path(display_id, size=nil)
				file = ImageHelper.abs_upload_image(display_id, size)
				unless file.nil?
					file.slice!(DOCUMENT_ROOT)
					file
				end
			end
			def ImageHelper.abs_upload_image(display_id, size=nil)
				pattern = File.join(ImageHelper.images_path(size), \
					display_id.to_s[-1,1], display_id.to_s + ".*") 
				Dir.glob(pattern).first
			end
		end
	end
end
