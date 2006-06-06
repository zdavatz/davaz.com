#!/usr/bin/env ruby
# View::Publictemplate -- davaz.com -- 27.07.2005 -- mhuggler@ywesee.com

require 'htmlgrid/divtemplate'
require 'htmlgrid/dojotoolkit'
require 'view/navigation'
require 'view/ticker'

module DAVAZ
	module View
		class FootContainer < HtmlGrid::DivComposite
			COMPONENTS = {
				[0,0]		=>	View::FootNavigation,
				[0,1]		=>	:copyright,
			}
			CSS_ID_MAP = {
				0	=>	'foot-navigation',
				1	=>	'copyright',
			}
			CSS_MAP = {
				0	=>	'column',
				1	=>	'column',
			}
			def copyright(model)
				span = HtmlGrid::Span.new(model, @session, self)
				span.value = @lookandfeel.lookup(:copyright)
				span.css_id = 'copyright'
				span
			end
		end
		class PublicTemplate < HtmlGrid::DivTemplate
			include HtmlGrid::DojoToolkit::DojoTemplate
			CSS_FILES = [ :navigation_css ]
			JAVASCRIPTS = [ 
				'davaz',
			]
			MOVIES_DIV_IMAGE_WIDTH = 185
			MOVIES_DIV_IMAGE_SPEED = 4000
			DOJO_DEBUG = true 
			DOJO_PREFIX = {
				'ywesee'	=>	'../javascript',
			}
			DOJO_REQUIRE = [
				'dojo.widget.*',
				'dojo.widget.Tooltip',
				'dojo.fx.*',
				'dojo.fx.html',
				'ywesee.widget.*',
				'ywesee.widget.OneLiner',
				'ywesee.widget.SlideShow',
				'ywesee.widget.Ticker'
			]
			CONTENT = nil
			TICKER = nil
			COMPONENTS = {
				[0,0]		=>	View::TopNavigation,
				[0,1]		=>	:container,
				[0,2]		=>	View::FootContainer,
				[0,3]		=>	:logo,	
				[0,4]		=>	:zone_image,
			}
			CSS_ID_MAP = {
				0		=>	'top-navigation',
				1		=>	'container',
				2		=>	'foot-container',
				3		=>	'logo',
				4		=>	'zone-image',
			}
			HTTP_HEADERS = {
				"Content-Type"	=>	"text/html; charset=UTF-8",
				"Cache-Control"	=>	"private, no-store, no-cache, must-revalidate, post-check=0, pre-check=0",
				"Pragma"				=>	"no-cache",
				"Expires"				=>	Time.now.rfc1123,
				"P3P"						=>	"CP='OTI NID CUR OUR STP ONL UNI PRE'",
			}			
			META_TAGS = [
				{
					"http-equiv"	=>	"robots",
					"content"			=>	"follow, index",
				},
			]
			def init
=begin
				if(display_id = @session.user_input(:show))
					script = "toggleHiddenDiv('#{display_id}-hidden-div')"
					self.onload = script
				end
=end
				super
			end
			def container(model)
				divs = []
				div = HtmlGrid::Div.new(model, @session, self)
				value = []
				unless(self::class::TICKER.nil?)
					slideshow_name = self::class::SLIDESHOW_NAME
					slides = @session.app.load_slideshow(slideshow_name)
					value <<  __standard_component(slides, self::class::TICKER) 
				end
				value <<  __standard_component(model, self::class::CONTENT)
				div.value = value
				div.css_id = 'content'
				div.css_class = 'column'
				divs << div
				div = HtmlGrid::Div.new(model, @session, self)
				div.css_id = 'left-navigation'
				div.css_class = 'column'
				div.value = View::LeftNavigation.new(model, @session, self)
				divs << div
				divs
			end
			def title(context)
				context.title { 
					[
						@lookandfeel.lookup(:html_title),
						@session.state.zone.to_s.capitalize,
						title_event
					].compact.join(@lookandfeel.lookup(:title_divider))
				}
			end
			def title_event
				event = @session.state.direct_event || @session.event
				@lookandfeel.lookup(event)
			end
			def logo(model)
				img = HtmlGrid::Image.new(:logo_ph, model, @session, self)
				link = HtmlGrid::Link.new(:no_name, model, @session, self)
				link.css_id = 'logo'
				link.href = @lookandfeel.event_url(:personal, :home)
				link.value = img
				link
			end
			def zone_image(model)
				img = HtmlGrid::Image.new(:topleft_ph, model, @session, self)
				link = HtmlGrid::Link.new(:no_name, model, @session, self)
				link.css_id = 'zone-image'
				link.href = @lookandfeel.event_url(:personal, :home)
				link.value = img
				link
			end
		end
		class CommonPublicTemplate < View::PublicTemplate
			#FOOT = View::FootNavigation
			#COMPONENTS.store([0,3], :foot)
		end
		class CommunicationPublicTemplate < View::CommonPublicTemplate
			CSS_FILES = [ :navigation_css, :communication_css ]
		end
		class PersonalPublicTemplate < View::CommonPublicTemplate
			CSS_FILES = [ :navigation_css, :personal_css ]
		end
		class MoviesPublicTemplate < View::CommonPublicTemplate
			CSS_FILES = [ :navigation_css, :movies_css ]
		end
		class DesignPublicTemplate < View::CommonPublicTemplate
			CSS_FILES = [ :navigation_css, :design_css ]
		end
		class DrawingsPublicTemplate < View::CommonPublicTemplate
			CSS_FILES = [ :navigation_css, :drawings_css ]
		end
		class PaintingsPublicTemplate < View::CommonPublicTemplate
			CSS_FILES = [ :navigation_css, :paintings_css ]
		end
		class MultiplesPublicTemplate < View::CommonPublicTemplate
			CSS_FILES = [ :navigation_css, :multiples_css ]
		end
		class PhotosPublicTemplate < View::CommonPublicTemplate
			CSS_FILES = [ :navigation_css, :photos_css ]
		end
		class SchnitzenthesenPublicTemplate < View::CommonPublicTemplate
			CSS_FILES = [ :navigation_css, :schnitzenthesen_css ]
		end
		class GallerySearchPublicTemplate < View::PublicTemplate
			CSS_FILES = [ :navigation_css, :gallery_css ]
		end
		class ArticlesPublicTemplate < View::CommonPublicTemplate
			CSS_FILES = [ :navigation_css, :articles_css ]
		end
		class LecturesPublicTemplate < View::CommonPublicTemplate
			CSS_FILES = [ :navigation_css, :lectures_css ]
		end
		class ExhibitionsPublicTemplate < View::CommonPublicTemplate
			CSS_FILES = [ :navigation_css, :exhibitions_css ]
		end
		class ImagesPublicTemplate < View::CommonPublicTemplate
			CSS_FILES = [ :navigation_css, :images_css ]
		end
	end
end
