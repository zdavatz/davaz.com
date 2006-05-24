#!/usr/bin/env ruby
# View::SlideshowRack -- davaz.com -- 03.05.2006 -- mhuggler@ywesee.com

require 'htmlgrid/dojotoolkit'
require 'htmlgrid/divcomposite'
require 'view/slideshow'
#require 'image_size'

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
				super
				div = HtmlGrid::Div.new(@model, @session, self)
				unless(@model.empty?)
					display_id = @model.first.display_id
					img = HtmlGrid::Image.new(display_id, @model, @session, self)
					url = @lookandfeel.upload_image_path(display_id)
					img.attributes['src'] = url
					img.css_id = 'image-container-image'
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
					@cwidth = (359/columns)-8
					@rheight = (359/rows)-8
					@css_style_map = [
						"width: #{@cwidth}px; height: #{@rheight}px; padding: 4px;"
					]
				end
				super
			end
			def image(model)
				display_id = model.display_id
				img = HtmlGrid::Image.new(display_id, model, @session, self)
				url = @lookandfeel.upload_image_path(display_id)
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
				link.attributes['onmouseover'] = "toggleImageSrc('image-container-image', '#{url}')"
				link.value = img
				link
			end
		end
		class Rack < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]	=>	ImageContainer,
				[0,1]	=>	RackContainer,
			}
			CSS_ID_MAP = {
				0	=>	'image-container',
				1	=>	'thumb-container',
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
	end
end
