#!/usr/bin/env ruby
# TestImageHelper -- davaz.com -- 31.05.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'fileutils'
require 'util/image_helper'
require 'util/davazconfig'
require 'RMagick'

module DAVAZ
	module Util
		class ImageHelper
			UPLOAD_IMAGES_PATH = '../../test/data/uploads/images'
			attr_reader :geometries
		end
	end
end

class ImageHelper < Test::Unit::TestCase
	def setup
		@helper = DAVAZ::Util::ImageHelper.new
		@images_path = File.expand_path('../data/uploads/images', File.dirname(__FILE__))
		@small_image_width = DAVAZ::SMALL_IMAGE_WIDTH.to_i
		@medium_image_width = DAVAZ::MEDIUM_IMAGE_WIDTH.to_i
		@large_image_width = DAVAZ::LARGE_IMAGE_WIDTH.to_i
		@slideshow_image_height = DAVAZ::SLIDESHOW_IMAGE_HEIGHT.to_i
	end
	def test_add_image 
		@helper.add_image('311')
		name = @helper.class.abs_image_path('311')
		image = Magick::Image.read(name).first
		assert_equal(349, image.columns)
		assert_equal(300, image.rows)
		@helper.geometries.each { |key, value|
			path = File.join(@images_path, key.to_s, '1/311.jpeg')
			assert(File.exists?(path))
			image = Magick::Image.read(path).first
			case key
			when :small
				assert_equal(@small_image_width, image.columns)
			when :medium
				assert_equal(@medium_image_width, image.columns)
			when :large
				assert_equal(@large_image_width, image.columns)
			when :slideshow
				assert_equal(@slideshow_image_height, image.rows)
			end
		}
		@helper.geometries.each { |key, value|
			path = DAVAZ::Util::ImageHelper.abs_image_path('311', key.to_s)
			FileUtils.rm(path)
		}	
		@helper.geometries.each { |key, value|
			path = File.join(@images_path, key.to_s, '1/311.jpeg')
			assert(!File.exists?(path))
		}
	end
	def test_image_path
		path = "/resources/../../test/data/uploads/images"
		file_path = File.expand_path("../data/uploads/images", \
			File.dirname(__FILE__))
		file = File.join(file_path, 'small', '1', '311.jpeg')
		File.open(file, 'w') { |file| file << "abcd" }
		result = @helper.class.image_path('311')
		expected = File.join(path, "1/311.jpeg")
		assert_equal(expected, result)
		@helper.geometries.each { |key, value|
			result = @helper.class.image_path('311', key.to_s)
			case key
			when :small
				expected = File.join(path, key.to_s, "1/311.jpeg")
			else
				expected = nil
			end
			assert_equal(expected, result)
		}
	end
	def test_abs_image_path
		result = @helper.class.abs_image_path('311')
		expected = File.expand_path("../../doc/", File.dirname(__FILE__))
		expected << "/resources/../../test/data/uploads/images/1/311.jpeg"
		assert_equal(expected, result)
	end
	def teardown
	end
end
