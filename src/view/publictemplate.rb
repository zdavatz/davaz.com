require 'htmlgrid/divtemplate'
require 'htmlgrid/dojotoolkit'
require 'htmlgrid/form'
require 'htmlgrid/link'
require 'htmlgrid/spanlist'
require 'view/navigation'
require 'view/ticker'

DOJO_VERSION = '1.7.7'

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
        [0, 0] => View::FootNavigation,
        [0, 1] => :copyright
      }
      CSS_ID_MAP = {
        0 => 'foot_navigation',
        1 => 'copyright',
      }
      CSS_MAP = {
        0 => 'column',
        1 => 'column',
      }

      def copyright(model)
        link = HtmlGrid::Link.new(:copyright, model, @session, self)
        link.href   = @lookandfeel.lookup(:copyright_url)
        link.value  = @lookandfeel.lookup(:copyright)
        link.css_id = 'copyright'
        link
      end
    end

    class PublicTemplate < HtmlGrid::DivTemplate
      include HtmlGrid::DojoToolkit::DojoTemplate

      CSS_FILES = [:navigation_css]
      JAVASCRIPTS = [
        'davaz'
      ]
      MOVIES_DIV_IMAGE_WIDTH = 185
      MOVIES_DIV_IMAGE_SPEED = 4000
      DOJO_DEBUG       = DAVAZ.config.dojo_debug
      DOJO_BACK_BUTTON = false
      DOJO_PREFIX      = {
        'ywesee' => '/resources/javascript'
      }
      DOJO_REQUIRE = [
        'dojo/ready',
        'dojo/back',
        'ywesee/widget/desk',
        #'ywesee/widget/LoginWidget',
        'ywesee/widget/oneliner',
        'ywesee/widget/rack',
        'ywesee/widget/show',
        'ywesee/widget/slide',
        'ywesee/widget/ticker',
        #'ywesee/widget/Tooltip',
        #'ywesee/widget/InputText',
        #'ywesee/widget/InputTextarea',
        #'ywesee/widget/EditWidget',
        #'ywesee/widget/EditButtons',
        #'ywesee/widget/GuestbookWidget',
      ]
      CONTENT = nil
      TICKER  = nil
      COMPONENTS = {
        [0, 0] => View::TopNavigation,
        [0, 1] => :dojo_container,
        [0, 2] => View::FootContainer,
        [0, 3] => :logo,
        [0, 4] => :zone_image,
      }
      CSS_ID_MAP = {
        0 => 'top_navigation',
        1 => 'container',
        2 => 'foot_container',
        3 => 'logo',
        4 => 'zone_image',
      }
      HTTP_HEADERS = {
        'Content-Type'  => 'text/html;charset=UTF-8',
        'Pragma'        => 'no-cache',
        'Expires'       => Time.now.rfc1123,
        'P3P'           => "CP='OTI NID CUR OUR STP ONL UNI PRE'",
        'Cache-Control' => <<~EOC.gsub(/\n/, ''),
          private,
          no-store,
          no-cache,
          must-revalidate,
          post-check=0,
          pre-check=0
        EOC
      }
      META_TAGS = [{
        'http-equiv' => 'robots',
        'content'    => 'follow, index',
      }]

      def dojo_container(model)
        divs = []
        div = HtmlGrid::Div.new(model, @session, self)
        value = []
        if ticker = self.class::TICKER
          artobjects = @session.app.load_tag_artobjects(ticker)
          value << __standard_component(artobjects, View::TickerContainer)
        end
        value << __standard_component(model, self::class::CONTENT)
        div.value     = value
        div.css_id    = 'content'
        div.css_class = 'column'
        divs << div
        div = HtmlGrid::Div.new(model, @session, self)
        div.css_id    = 'left_navigation_container'
        div.css_class = 'column'
        div.value = View::LeftNavigation.new(model, @session, self)
        divs << div
        # dojo/back
        self.onload = sprintf(
          "back.setInitialState('%s');", @session.request_path)
        divs
      end

      def title(context)
        context.title {
          [@lookandfeel.lookup(:html_title), title_zone, title_event].compact \
            .join(@lookandfeel.lookup(:title_divider))
        }
      end

      def title_event
        @lookandfeel.lookup(@session.state.direct_event || @session.event)
      end

      def title_zone
        (@session.state.zone || @session.user_input(:zone)).to_s.capitalize
      end

      def logo(model)
        img = HtmlGrid::Image.new(:logo_ph, model, @session, self)
        link = HtmlGrid::Link.new(:no_name, model, @session, self)
        link.css_class = 'logo_ph'
        link.href      = @lookandfeel.event_url(:personal, :home)
        link.value     = img
        link
      end

      def zone_image(model)
        img = HtmlGrid::Image.new(:topleft_ph, model, @session, self)
        link = HtmlGrid::Link.new(:no_name, model, @session, self)
        link.css_id = 'zone_image'
        link.href   = @lookandfeel.event_url(:personal, :home)
        link.value  = img
        link
      end
    end

    class CommonPublicTemplate < View::PublicTemplate
    end

    class AdminDesignPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css design_css admin_css}
    end

    class AdminDrawingsPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css drawings_css admin_css}
    end

    class AdminGalleryPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css gallery_css admin_css}
    end

    class AdminMoviesPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css movies_css admin_css}
    end

    class AdminPaintingsPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css paintings_css admin_css}
    end

    class AdminPersonalPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css personal_css admin_css}
    end

    class AdminPhotosPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css photos_css admin_css}
    end

    class AdminSchnitzenthesenPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css schnitzenthesen_css admin_css}
    end

    class ArticlesPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css articles_css}
    end

    class CommunicationPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css communication_css}
    end

    class CommunicationAdminPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css communication_css admin_css communication_admin_css}
    end

    class DesignPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css design_css}
    end

    class DrawingsPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css drawings_css}
    end

    class ExhibitionsPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css exhibitions_css}
    end

    class GalleryPublicTemplate < View::PublicTemplate
      CSS_FILES = %i{navigation_css gallery_css}
    end

    class ImagesPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css images_css}
    end

    class PaintingsPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css paintings_css}
    end

    class LecturesPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css lectures_css}
    end

    class MultiplesPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css multiples_css}
    end

    class MoviesPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css movies_css}
    end

    class PersonalPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css personal_css}
    end

    class PhotosPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css photos_css}
    end

    class SchnitzenthesenPublicTemplate < View::CommonPublicTemplate
      CSS_FILES = %i{navigation_css schnitzenthesen_css}
    end
  end
end
