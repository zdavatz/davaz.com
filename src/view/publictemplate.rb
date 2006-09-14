#!/usr/bin/env ruby
# View::Publictemplate -- davaz.com -- 27.07.2005 -- mhuggler@ywesee.com

require 'htmlgrid/divtemplate'
require 'htmlgrid/dojotoolkit'
require 'htmlgrid/form'
require 'htmlgrid/link'
require 'htmlgrid/spanlist'
require 'view/navigation'
require 'view/ticker'

module HtmlGrid
	module FormMethods
		remove_const(:ACCEPT_CHARSET)
		ACCEPT_CHARSET = 'UTF-8'
	end
end
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
				link = HtmlGrid::Link.new(:copyright, model, @session, self)
				link.href = @lookandfeel.lookup(:copyright_url)
				link.value = @lookandfeel.lookup(:copyright)
				link.css_id = 'copyright'
				link
			end
		end
		class PublicTemplate < HtmlGrid::DivTemplate
			include HtmlGrid::DojoToolkit::DojoTemplate
			CSS_FILES = [ :navigation_css ]
			JAVASCRIPTS = [ 
				'davaz', #'historyAndBookmarking'
			]
			MOVIES_DIV_IMAGE_WIDTH = 185
			MOVIES_DIV_IMAGE_SPEED = 4000
			DOJO_DEBUG = true 
			DOJO_BACK_BUTTON = false 
			DOJO_PREFIX = {
				'ywesee'	=>	'../javascript',
			}
			DOJO_REQUIRE = [
				'dojo.debug.Firebug',
				'dojo.widget.*',
				'dojo.widget.Tooltip',
				'dojo.lfx.*',
				'dojo.lfx.html',
				'dojo.io.IframeIO',
				'dojo.lang.*',
				'dojo.undo.browser',
				'dojo.widget.Tree',
				'dojo.widget.TreeRPCController',
				'dojo.widget.TreeSelector',
				'dojo.widget.TreeNode',
				'dojo.widget.TreeContextMenu',
				'ywesee.widget.*',
				'ywesee.widget.Desk',
				'ywesee.widget.OneLiner',
				'ywesee.widget.SlideShow',
				'ywesee.widget.Rack',
				'ywesee.widget.Ticker',
				'ywesee.widget.Input',
				'ywesee.widget.InputText',
				'ywesee.widget.InputTextarea',
				'ywesee.widget.EditWidget',
				'ywesee.widget.EditButtons',
				'ywesee.widget.LoginWidget',
			]
			CONTENT = nil
			TICKER = nil
			COMPONENTS = {
				[0,0]		=>	View::TopNavigation,
				[0,1]		=>	:dojo_container,
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
			def dojo_container(model)
				divs = []
				div = HtmlGrid::Div.new(model, @session, self)
				value = []
				if(ticker = self.class::TICKER)
					artobjects = @session.app.load_tag_artobjects(ticker)
					value <<  __standard_component(artobjects, View::TickerContainer) 
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
						title_zone,
						title_event,
					].compact.join(@lookandfeel.lookup(:title_divider))
				}
			end
			def title_event
				event = @session.state.direct_event || @session.event
				@lookandfeel.lookup(event)
			end
			def title_zone
				zone = @session.state.zone
				if(zone.nil?)
					zone = @session.user_input(:zone)
				end
				zone.to_s.capitalize
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
		class CommunicationAdminPublicTemplate < View::CommonPublicTemplate
			CSS_FILES = [ :navigation_css, :communication_css, :communication_admin_css ]
		end
		class AdminPersonalPublicTemplate < View::CommonPublicTemplate
			CSS_FILES = [ :navigation_css, :personal_css, :admin_css ]
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
		class GalleryPublicTemplate < View::PublicTemplate
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
		class AdminGalleryPublicTemplate < View::CommonPublicTemplate
			CSS_FILES = [ :navigation_css, :gallery_css, :admin_css ]
		end
	end
end
