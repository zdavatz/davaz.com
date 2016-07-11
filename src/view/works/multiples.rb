#!/usr/bin/env ruby
# View::Works::Multiples -- davaz.com -- 28.09.2005 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/divcomposite'
require 'htmlgrid/spanlist'
require 'util/image_helper'
require 'view/add_onload'

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
class JavaApplet < HtmlGrid::Component 
	def init
		super
		image = Util::ImageHelper.image_url(@model)
		@value = <<-EOS
			<applet name="ptviewer" valign=bottom border=0 hspace=0 vspace=0 archive="/resources/java/ptviewer.jar" code=ptviewer.class width="380" height="200" mayscript=true>
        <param name=file 		value="ptviewer:0">
				<param name=frame		value="/resources/images/global/control.gif">
        <param name=bar_x 		value="198">
        <param name=bar_y 		value="163">
        <param name=bar_width 	value="165">
        <param name=bar_height 	value="23">
        <param name=inits		value="ptviewer:startApplet(1)">
        <param name=shotspot0   value=" x310 y186 a324 b200 u'ptviewer:startAutoPan(0.5,0,1)' ">
        <param name=shotspot1   value=" x324 y186 a338 b200 u'ptviewer:stopAutoPan()' ">
        <param name=shotspot2   value=" x338 y186 a352 b200 u'ptviewer:startAutoPan(0,0,0.97)' ">
        <param name=shotspot3   value=" x352 y186 a366 b200 u'ptviewer:startAutoPan(0,0,1.03)' ">
        <param name=shotspot4   value=" x366 y186 a380 b200 u'ptviewer:gotoView(0,0,80)' ">
				<param name=pano0		value=" {file=#{image}}
												    {pan=-45}
												    {tilt=-50}
												    {fov=120}
												    {fovmax=120}
												    {fovmin=30}
												    {auto=0.5}
												    {mousehs=mousehs}
												    {getview=getview} ">
														<param name=wait		value="#{image}">
      </applet>
		EOS
	end
end
class JavaAppletDiv < HtmlGrid::Div
  CSS_ID = 'java_applet'
end
class ThumbImages < HtmlGrid::SpanList 
	COMPONENTS = {
		[0,0]	=>	:image,
	}
	def image(model)
		link = HtmlGrid::Link.new(:serie_link, model, @session, self)
		link.href = "javascript:void(0);" 
		artobject_id = model.artobject_id
		args =[ [ :artobject_id, artobject_id ] ]
		url = @lookandfeel.event_url(:works, :ajax_multiples, args)
		script = "toggleJavaApplet('#{url}','#{artobject_id}');"
		link.set_attribute('onclick', script)
		img = HtmlGrid::Image.new(artobject_id, model, @session, self)
		url = DAVAZ::Util::ImageHelper.image_url(artobject_id, 'medium')
		img.attributes['width']	= DAVAZ.config.small_image_width 
		img.attributes['src'] = url
		img.css_class = 'thumb-image'
		link.value = img 
		link
	end
end
class ThumbImagesDiv < HtmlGrid::Div
  CSS_ID = 'thumb_images'
end
class MultiplesComposite < HtmlGrid::DivComposite
	CSS_CLASS = 'content'
	COMPONENTS = {
		[0,0]	=>	MultiplesTitle,
		[0,1]	=>	JavaAppletDiv,
		[0,2]	=>	component(ThumbImages, :multiples),
	}
  CSS_ID_MAP = {
    2 => 'thumb_images',
  }
end
class Multiples < View::MultiplesPublicTemplate
	CONTENT = View::Works::MultiplesComposite 
	def init
		super
		args =[ [ :artobject_id, '' ] ]
		url = @lookandfeel.event_url(:works, :ajax_multiples, args)
		script = <<-EOS
			if(!location.hash) {
				location.hash = '#{@model.default_artobject_id}';
				artobject_id = '#{model.default_artobject_id}';
			} else {
				var artobject_id = location.hash.substring(1, location.hash.length);
			} 
			var url = '#{url}' + artobject_id;
			toggleJavaApplet(url, artobject_id);
		EOS
		self.onload = script
	end
end
		end
	end
end
