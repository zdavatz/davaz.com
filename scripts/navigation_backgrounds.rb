#!/usr/bin/env ruby
# NavigationBackgrounds -- davaz.com -- 01.06.2006 -- mhuggler@ywesee.com

require 'RMagick'
require 'src/util/davazconfig'

module DAVAZ
	class NavigationBackgrounds
		include Magick
		def write_pngs
			path = File.expand_path("../doc/resources/images/navigation", \
				File.dirname(__FILE__))
			COLORS.each { |key, color|
				gradient = GradientFill.new(0,0,0,200,'#ffffff', color)
				img = Image.new(200,20, gradient)
				file_path = File.join(path, "#{key.to_s}.png")
				img.write(file_path)
			}
		end
	end
end

DAVAZ::NavigationBackgrounds.new.write_pngs
