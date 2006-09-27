#!/usr/bin/env ruby
# ImageHelper -- davaz.com -- 31.05.2006 -- mhuggler@ywesee.com

require 'RMagick'
require "util/config"
require "util/davaz"

module DAVAZ
	module Util 
		class ImageHelper
			include Magick	
			@@geometries = {
				:small	=>	Geometry.new(DAVAZ.config.small_image_width.to_i),
				:medium	=>	Geometry.new(DAVAZ.config.medium_image_width.to_i),
				:large	=>	Geometry.new(DAVAZ.config.large_image_width.to_i),
				:slideshow	=>	Geometry.new(nil, DAVAZ.config.slideshow_image_height.to_i),
			}
			def ImageHelper.abs_image_path(artobject_id, size=nil)
				pattern = File.join(ImageHelper.images_path(size), \
					artobject_id.to_s[-1,1], artobject_id.to_s + ".*") 
				Dir.glob(pattern).first
			end
			def ImageHelper.delete_image(artobject_id)
				path = ImageHelper.abs_image_path(artobject_id)
				unless(path.nil?)
					File.unlink(path) #unless path.nil?
				end
				@@geometries.each { |key, value|
					path = ImageHelper.abs_image_path(artobject_id, key)
					unless(path.nil?)
						File.unlink(path) #unless path.nil?
					end
				}
			end
			def ImageHelper.has_image?(artobject_id)
				if(ImageHelper.abs_image_path(artobject_id).nil?)
					false
				else
					true
				end
			end
			def ImageHelper.abs_tmp_path
				dir_components = [
					DAVAZ.config.document_root,
					"resources",
					DAVAZ.config.tmp_images_path,
				]
				dir_components.join("/")
			end
			def ImageHelper.images_path(size=nil)
				dir_components = [
					DAVAZ.config.document_root,
					"resources",
					DAVAZ.config.upload_images_path
				]
				dir_components.push(size) unless size.nil?
				dir_components.join("/")
			end
			def ImageHelper.image_path(artobject_id, size=nil, \
					timestamp=false)
				return nil if artobject_id.nil?
				path = ImageHelper.abs_image_path(artobject_id, size)
				return nil if path.nil?
				if(timestamp)
					path += sprintf("?time=%i", File.mtime(path))
				end
				unless path.nil?
					path.slice!(DAVAZ.config.document_root)
					path
				end
			end
			def ImageHelper.resize_image(artobject_id, image)
				@@geometries.each { |key, value| 
					image.change_geometry(value) { |cols, rows, img|
						store_image(artobject_id, img.resize(cols, rows), key)
					}	
				}
			end
			def ImageHelper.store_image(artobject_id, image, key=nil)
				path = ImageHelper.images_path(key.to_s)
				directory = artobject_id[-1,1]
				name = [
					path,
					directory,
					"#{artobject_id}.#{image.format.downcase}",
				].join("/") 
				image.write(name)
			end
			def ImageHelper.store_upload_image(string_io, artobject_id)
				if(ImageHelper.has_image?(artobject_id))
					ImageHelper.delete_image(artobject_id)	
				end
				image = Image.from_blob(string_io.read).first
				extension = image.format.downcase
				path = File.join(ImageHelper.images_path, \
					artobject_id.to_s[-1,1], artobject_id.to_s + "." + extension) 
				image.write(path)
				ImageHelper.resize_image(artobject_id.to_s, image)
			end
			def ImageHelper.store_tmp_image(tmp_path, artobject_id)
				image = Image.read(tmp_path).first
				extension = image.format.downcase
				path = File.join(
					ImageHelper.images_path,
					artobject_id.to_s[-1,1], 
					artobject_id.to_s + "." + extension
				) 
				image.write(path)
				ImageHelper.resize_image(artobject_id.to_s, image)
				File.delete(tmp_path)
			end
		end
	end
end
