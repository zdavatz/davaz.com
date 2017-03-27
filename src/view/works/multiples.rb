require 'htmlgrid/divcomposite'
require 'htmlgrid/component'
require 'htmlgrid/div'
require 'htmlgrid/spanlist'
require 'util/image_helper'
require 'view/template'

module DaVaz::View
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

    module PanoramaMethods
      def panorama_src(artobject_id)
        # pannellum
	require 'pry'; binding.pry
        url = '/resources/javascript/pannellum/pannellum.htm?panorama='
        url += DaVaz::Util::ImageHelper.image_url(artobject_id, 'slide')
        url += '&autoLoad=true'
        url += '&autoRotate=1'
        url
      end
    end

    class PanoramaDiv < HtmlGrid::Div
      CSS_ID = 'panorama'

      def init
        @value = <<~EOS.gsub(/\n/, '')
          <iframe id="panorama_frame" width="455" height="180" allowfullscreen
           style="border-style:none;" src=""></iframe>
        EOS
      end
    end

    class ThumbImages < HtmlGrid::SpanList
      include PanoramaMethods

      COMPONENTS = {
        [0, 0] => :image,
      }

      def image(model)
        artobject_id = model.artobject_id
        # pannellum
        url = panorama_src(artobject_id)
        link = HtmlGrid::Link.new(:serie_link, model, @session, self)
        link.href = 'javascript:void(0);'
        link.set_attribute('onclick', <<~EOS)
          return togglePanorama('#{url}');
        EOS
        img = HtmlGrid::Image.new(artobject_id, model, @session, self)
        img.attributes['width'] = DaVaz.config.small_image_width
        img.attributes['src']   = DaVaz::Util::ImageHelper.image_url(
          artobject_id, 'medium')
        img.css_class = 'thumb-image'
        link.value = img
        link
      end
    end

    class ThumbImagesDiv < HtmlGrid::Div
      CSS_ID = 'thumb_images'
    end

    class MultiplesComposite < HtmlGrid::DivComposite
      CSS_CLASS  = 'content'
      COMPONENTS = {
        [0, 0] => MultiplesTitle,
        [0, 1] => PanoramaDiv,
        [0, 2] => component(ThumbImages, :multiples),
      }
      CSS_ID_MAP = {
        2 => 'thumb_images',
      }
    end

    class Multiples < MultiplesTemplate
      include PanoramaMethods

      CONTENT = MultiplesComposite

      def init
        super
        self.onload = <<~EOS.gsub(/\n/, '')
          (function() {
            var frame = document.getElementById('panorama_frame');
            if (location.href.match(/\\/works\\/multiples\\/?$/i)) {
              togglePanorama('#{panorama_src(@model.default_artobject_id)}');
            }
          })();
        EOS
      end
    end
  end
end
