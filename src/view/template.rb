require 'htmlgrid/divtemplate'
require 'htmlgrid/dojotoolkit'
require 'htmlgrid/form'
require 'htmlgrid/link'
require 'htmlgrid/spanlist'
require 'view/_partial/navigation'
require 'view/_partial/ticker'

DOJO_VERSION = '1.7.7'

module HtmlGrid
  module FormMethods
    remove_const(:ACCEPT_CHARSET)
    ACCEPT_CHARSET = 'UTF-8'
  end
end

module DaVaz::View
  class FootContainer < HtmlGrid::DivComposite
    COMPONENTS = {
      [0, 0] => FootNavigation,
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

  class Template < HtmlGrid::DivTemplate
    include HtmlGrid::DojoToolkit::DojoTemplate

    CSS_FILES = [:navigation_css]
    JAVASCRIPTS = [
      'davaz'
    ]
    MOVIES_DIV_IMAGE_WIDTH = 185
    MOVIES_DIV_IMAGE_SPEED = 4000
    DOJO_DEBUG       = DaVaz.config.dojo_debug
    DOJO_BACK_BUTTON = false
    DOJO_PREFIX      = {
      'ywesee' => '/resources/javascript'
    }
    DOJO_REQUIRE = %w{
      dojo/ready
      dojo/back
      ywesee/widget/oneliner
      ywesee/widget/ticker
      ywesee/widget/slide
      ywesee/widget/guestbook
    }
    CONTENT = nil
    TICKER  = nil
    COMPONENTS = {
      [0, 0] => TopNavigation,
      [0, 1] => :dojo_container,
      [0, 2] => FootContainer,
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
        value << __standard_component(artobjects, TickerContainer)
      end
      value << __standard_component(model, self::class::CONTENT)
      div.value     = value
      div.css_id    = 'content'
      div.css_class = 'column'
      divs << div
      div = HtmlGrid::Div.new(model, @session, self)
      div.css_id    = 'left_navigation_container'
      div.css_class = 'column'
      div.value = left_navigation(model)
      divs << div
      # dojo/back
      self.onload = sprintf(
        "back.setInitialState('%s');", @session.request_path)
      divs
    end

    def left_navigation(model)
      LeftNavigation.new(model, @session, self)
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

  class CommonTemplate < Template
  end

  class DesignTemplate < CommonTemplate
    CSS_FILES = %i{navigation_css design_css}
  end

  class DrawingsTemplate < CommonTemplate
    CSS_FILES = %i{navigation_css drawings_css}
  end

  class ExhibitionsTemplate < CommonTemplate
    CSS_FILES = %i{navigation_css exhibitions_css}
  end

  class GalleryTemplate < CommonTemplate
    CSS_FILES = %i{navigation_css gallery_css}
  end

  class ImagesTemplate < CommonTemplate
    CSS_FILES = %i{navigation_css images_css}
  end

  class PaintingsTemplate < CommonTemplate
    CSS_FILES = %i{navigation_css paintings_css}
  end

  class LecturesTemplate < CommonTemplate
    CSS_FILES = %i{navigation_css lectures_css}
  end

  class MultiplesTemplate < CommonTemplate
    CSS_FILES   = %i{navigation_css multiples_css pannellum_css}
    JAVASCRIPTS = ['davaz', 'pannellum/pannellum']
  end

  class MoviesTemplate < CommonTemplate
    CSS_FILES = %i{navigation_css movies_css}
  end

  class PersonalTemplate < CommonTemplate
    CSS_FILES = %i{navigation_css personal_css}
  end

  class PhotosTemplate < CommonTemplate
    CSS_FILES = %i{navigation_css photos_css}
  end

  class SchnitzenthesenTemplate < CommonTemplate
    CSS_FILES = %i{navigation_css schnitzenthesen_css}
  end

  class ArticlesTemplate < CommonTemplate
    CSS_FILES = %i{navigation_css articles_css}
  end

  class CommunicationTemplate < CommonTemplate
    CSS_FILES = %i{navigation_css communication_css}
  end

  class AdminTemplate < CommonTemplate
    DOJO_REQUIRE = CommonTemplate::DOJO_REQUIRE + %w{
      dijit/Editor
      ywesee/widget/live_editor
    }

    def left_navigation(model)
      AdminLeftNavigation.new(model, @session, self)
    end
  end

  class AdminDesignTemplate < AdminTemplate
    CSS_FILES = %i{navigation_css design_css admin_css}
  end

  class AdminDrawingsTemplate < AdminTemplate
    CSS_FILES = %i{navigation_css drawings_css admin_css}
  end

  class AdminGalleryTemplate < AdminTemplate
    CSS_FILES = %i{navigation_css gallery_css admin_css}
  end

  class AdminMoviesTemplate < AdminTemplate
    CSS_FILES = %i{navigation_css movies_css admin_css}
  end

  class AdminPaintingsTemplate < AdminTemplate
    CSS_FILES = %i{navigation_css paintings_css admin_css}
  end

  class AdminPersonalTemplate < AdminTemplate
    CSS_FILES = %i{navigation_css personal_css admin_css}
  end

  class AdminPhotosTemplate < AdminTemplate
    CSS_FILES = %i{navigation_css photos_css admin_css}
  end

  class AdminSchnitzenthesenTemplate < AdminTemplate
    CSS_FILES = %i{navigation_css schnitzenthesen_css admin_css}
  end

  class AdminArticlesTemplate < AdminTemplate
    CSS_FILES = %i{navigation_css articles_css admin_css}
  end

  class AdminLecturesTemplate < AdminTemplate
    CSS_FILES = %i{navigation_css lectures_css admin_css}
  end

  class AdminExhibitionsTemplate < AdminTemplate
    CSS_FILES = %i{navigation_css exhibitions_css admin_css}
  end

  class AdminCommunicationTemplate < AdminTemplate
    CSS_FILES = %i{
      navigation_css communication_css admin_css communication_admin_css
    }
  end
end
