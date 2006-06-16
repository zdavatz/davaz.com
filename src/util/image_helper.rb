#!/usr/bin/env ruby
# ImageHelper -- davaz.com -- 31.05.2006 -- mhuggler@ywesee.com

require 'RMagick'

module DAVAZ
	module Util 
		class ImageHelper
			include Magick	
			UPLOAD_IMAGES_PATH = 'uploads/images'
			GEOMETRIES = {
				:small			=>	Geometry.new(SMALL_IMAGE_WIDTH.to_i),
				:medium			=>	Geometry.new(MEDIUM_IMAGE_WIDTH.to_i),
				:large			=>	Geometry.new(LARGE_IMAGE_WIDTH.to_i),
				:slideshow	=>	Geometry.new(nil, SLIDESHOW_IMAGE_HEIGHT.to_i),
			}
			def ImageHelper.images_path(size=nil)
				dir_components = [
					DOCUMENT_ROOT,
					"resources",
					UPLOAD_IMAGES_PATH,
				]
				dir_components.push(size) unless size.nil?
				dir_components.join("/")
			end
			def ImageHelper.image_path(display_id, size=nil)
				return nil if display_id.nil?
				file = ImageHelper.abs_image_path(display_id, size)
				unless file.nil?
					file.slice!(DOCUMENT_ROOT)
					file
				end
			end
			def ImageHelper.abs_image_path(display_id, size=nil)
				pattern = File.join(ImageHelper.images_path(size), \
					display_id.to_s[-1,1], display_id.to_s + ".*") 
				Dir.glob(pattern).first
			end
			def ImageHelper.store_upload_image(string_io, display_id)
				image = Image.from_blob(string_io.read).first
				extension = image.format.downcase
				path = File.join(ImageHelper.images_path(nil), \
					display_id.to_s[-1,1], display_id.to_s + "." + extension) 
				image.write(path)
				ImageHelper.resize_image(display_id.to_s, image)
			end
			def ImageHelper.resize_image(display_id, image)
				GEOMETRIES.each { |key, value| 
					image.change_geometry(value) { |cols, rows, img|
						store_image(display_id, img.resize(cols, rows), key)
					}	
				}
			end
			def ImageHelper.store_image(display_id, image, key)
				path = ImageHelper.images_path(key.to_s)
				directory = display_id[-1,1]
				name = [
					path,
					directory,
					"#{display_id}.#{image.format.downcase}",
				].join("/") 
				image.write(name)
			end
		end
	end
end
