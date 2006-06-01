#!/usr/bin/env ruby
# View::Works::Multiples -- davaz.com -- 28.09.2005 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/divcomposite'
require 'htmlgrid/spanlist'
require 'util/image_helper'

module DAVAZ
	module View
		module Works
class MultiplesTitle < HtmlGrid::Div
	CSS_CLASS = 'table-title'
	def init
		super
		span = HtmlGrid::Span.new(model, @session, self)
		span.css_class = 'table-title'
		span.value = @lookandfeel.lookup(:multiples)
		@value = span
	end
end
class JavaAppletDiv < HtmlGrid::Div
	CSS_ID = "java-applet"
	def init
		super
		image = DAVAZ::Util::ImageHelper.image_path(@model.display_id)
		@value = <<-EOS
<applet name="ptviewer" archive="/resources/java/ptviewer.jar" codebase="/Library"  code="ptviewer.class"  width="320" height="200">
	<param name="file"    value="#{image}">
	<param name=pan     value="-45">
	<param name=tilt    value="-50">
	<param name=fov     value="80">
	<param name=fovmax    value="120">
	<param name=fovmin    value="30">
	<param name=auto    value="0.5">
	<param name=bar_x     value="115">
	<param name=bar_y     value="169">
	<param name=bar_width   value="193">
	<param name=bar_height  value="20">
	<param name=tiltmin   value="-85">
	<param name="HFOV"    value="360">
	<param name="VFOV"    value="0">
</applet>
<br>
<img src="/resources/images/global/control.gif" usemap="#control" border="0" width="56" height="14"><map name="control"><area shape="rect" coords="0,0,14,14" alt="Autorotation Start" href="javascript:DoAutorotationStart()"><area shape="rect" coords="14,0,28,14" alt="Autorotation Stop"  href="javascript:DoAutorotationStop()"> <area shape="rect" coords="28,0,42,14" alt="Zoom In" href="javascript:DoZoomIn()"> <area shape="rect" coords="42,0,56,14" alt="Zoom Out" href="javascript:DoZoomOut()"></map>
		EOS
	end
end
class ThumbImages < HtmlGrid::SpanList 
	COMPONENTS = {
		[0,0]	=>	:image,
	}
	def image(model)
		link = HtmlGrid::Link.new(:serie_link, model, @session, self)
		link.href = @lookandfeel.event_url(:works, @session.event, model.artobject_id)
		display_id = model.display_id
		img = HtmlGrid::Image.new(display_id, model, @session, self)
		url = DAVAZ::Util::ImageHelper.image_path(display_id, 'medium')
		img.attributes['width']	= SMALL_IMAGE_WIDTH 
		img.attributes['src'] = url
		img.css_class = 'thumb-image'
		link.value = img 
		link
	end
end
class ThumbImagesDiv < HtmlGrid::Div
	CSS_ID = 'thumb-images'
	def init
		super
		model = @session.app.load_multiples()
		@value = ThumbImages.new(model, @session, self)
	end
end
class MultiplesComposite < HtmlGrid::DivComposite
	CSS_CLASS = 'content'
	COMPONENTS = {
		[0,0]	=>	MultiplesTitle,
		[0,1]	=>	JavaAppletDiv,
		[0,2]	=>	ThumbImagesDiv,
	}
end
class Multiples < View::MultiplesPublicTemplate
	CONTENT = View::Works::MultiplesComposite 
end
		end
	end
end
