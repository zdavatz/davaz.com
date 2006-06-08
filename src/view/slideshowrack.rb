#!/usr/bin/env ruby
# View::SlideshowRack -- davaz.com -- 03.05.2006 -- mhuggler@ywesee.com

require 'htmlgrid/dojotoolkit'
require 'htmlgrid/divcomposite'
require 'view/slideshow'
require 'util/image_helper'

module DAVAZ
	module View
		class MultimediaButtonsComposite < HtmlGrid::DivComposite
			CSS_CLASS = 'multimedia-control'
			COMPONENTS = {
				[0,0]	=>	:rack,
				[0,0,1]	=>	:show,
				[0,0,2]	=>	:desk,
			}
			def rack(model)
				img = HtmlGrid::Image.new(:rack, model, @session, self)
				link = HtmlGrid::Link.new(:slideshow, model, @session, self)
				link.href = "javascript:void(0)"
				link.attributes['onclick'] = "toggleSlideshow()"
				link.value = img
				link
			end
			def show(model)
				img = HtmlGrid::Image.new(:show, model, @session, self)
				link = HtmlGrid::Link.new(:slideshow, model, @session, self)
				link.href = "javascript:void(0)"
				link.attributes['onclick'] = "toggleSlideshow()"
				link.value = img
				link
			end
			def desk(model)
				img = HtmlGrid::Image.new(:desk, model, @session, self)
				img
			end
		end
		class MultimediaButtons < HtmlGrid::DivComposite
			CSS_CLASS = 'multimedia-buttons'
			COMPONENTS = {
				[0,0,1]	=>	MultimediaButtonsComposite,
			}
		end
		class ImageContainer < HtmlGrid::Div
			def init
				unless(@model.empty?)
					image = @model.first
					display_id = image.display_id
					img = HtmlGrid::Image.new(display_id, @model, @session, self)
					url = DAVAZ::Util::ImageHelper.image_path(display_id)
					img.set_attribute('src', url)
					img.css_id = 'image-container-image'
					style = [
						"max-width: #{LARGE_IMAGE_WIDTH}",
						"max-height: 340px"
					]
					img.set_attribute('style', style.join(";"))
					@value = img
				else
					div = HtmlGrid::Div.new(@model, @session, self)
					div.css_id = 'no-works'
					div.value = @lookandfeel.lookup(:no_works) 
					@value = div 
				end
			end
		end
		class RackContainer < HtmlGrid::DivList
			CSS_CLASS = 'thumb-container'
			COMPONENTS = {
				[0,0]	=>	:image,
			}
			def init
				unless(@model.empty?)
					count = @model.size
					columns = Math.sqrt(count).round
					rows = (count.to_f/columns.to_f).ceil
					@cwidth = (349/columns)-8
					@rheight = (349/rows)-8
					@css_style_map = [
						"width: #{@cwidth}px; height: #{@rheight}px; padding: 4px;"
					]
				end
				super
			end
			def image(model)
				display_id = model.display_id
				img = HtmlGrid::Image.new(display_id, model, @session, self)
				url = DAVAZ::Util::ImageHelper.image_path(display_id)
				img.attributes['src'] = url
				img.css_id = 'thumb-container'
=begin
				open("/home/maege/cogito/davaz.com/doc/"+url, "rb") do |fh|
					image = ImageSize.new(fh.read)
					width = image.get_width
					height = image.get_height
					if(width > height)
						img.attributes['width'] = @cwidth
					else
						img.attributes['height'] = @rheight
					end
				end
=end
				link = HtmlGrid::Link.new(display_id, model, @session, self)
				link.href = "javascript:void(0)"
				image_id = 'image-container-image'
				title_id = 'image-title-span'
				title = model.title 
				script = "toggleRackImage('#{image_id}','#{url}','#{title_id}','#{title}')"
				link.attributes['onmouseover'] = script 
				link.value = img
				link
			end
		end
		class ImageTitle < HtmlGrid::Span
			CSS_ID = 'image-title-span'
			def init
				image = @model.first
				@value = image.title unless image.nil?
			end
		end
		class Rack < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]	=>	ImageContainer,
				[0,1]	=>	RackContainer,
				[0,2]	=>	ImageTitle, 
			}
			CSS_ID_MAP = {
				0	=>	'image-container',
				1	=>	'thumb-container',
				2	=>	'image-title-container',
			}
		end
		class SlideshowDiv < HtmlGrid::Div
			CSS_ID = 'slideshow'
			def init
				super
				@value = Slideshow.new(@model, @session, self)
			end
		end
		class SlideShowRackInnerComposite < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]	=>	Rack,
				[0,1]	=>	Slideshow,
			}
			CSS_ID_MAP = {
				0	=> 'rack',
				1	=>	'slideshow',
			}
		end
		class SlideShowRackComposite < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]	=>	SlideShowRackInnerComposite,
				[0,1]	=>	MultimediaButtons,
			}
			CSS_ID_MAP = {
				0	=>	'rack-container',
			}
		end
		class SearchSlideShowRackComposite < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]	=>	:close_x,
				[0,1]	=>	SlideShowRackInnerComposite,
				[0,2]	=>	MultimediaButtons,
			}
			CSS_ID_MAP = {
				0	=>	'close-x',
				1	=>	'rack-container',
			}
			def close_x(model)
				link = HtmlGrid::Link.new('close', model, @session, self)
				link.href = 'javascript:void(0)'
				link.value = "X"
				script = "closeSearchSlideShowRack()"
				link.set_attribute('onclick', script)
				link
			end
		end
	end
end
