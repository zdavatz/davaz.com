require 'htmlgrid/dojotoolkit'
require 'htmlgrid/divcomposite'
require 'view/serie_widget'
require 'util/image_helper'

module DAVAZ
  module View
    class MultimediaButtonsComposite < HtmlGrid::DivComposite
      CSS_CLASS  = 'multimedia-control'
      COMPONENTS = {
        [0, 0]    => :rack,
        [0, 0, 1] => :show,
        [0, 0, 2] => :desk,
      }

      def rack(model)
        img = HtmlGrid::Image.new(:rack, model, @session, self)
        link = HtmlGrid::Link.new(:rack, model, @session, self)
        link.value = img
        link.href  = 'javascript:void(0)'
        link.set_attribute('onclick', <<~TGGL)
          toggleShow('show', null, 'rack', 'show_wipearea', null);
        TGGL
        link
      end

      def show(model)
        img = HtmlGrid::Image.new(:show, model, @session, self)
        link = HtmlGrid::Link.new(:slideshow, model, @session, self)
        link.value = img
        link.href  = 'javascript:void(0)'
        link.set_attribute('onclick', <<~TGGL)
          toggleShow('show', null, 'slide', 'show_wipearea', null);
        TGGL
        link
      end

      def desk(model)
        img = HtmlGrid::Image.new(:desk, model, @session, self)
        link = HtmlGrid::Link.new(:desk, model, @session, self)
        link.value = img
        link.href  = 'javascript:void(0)'
        link.set_attribute('onclick', <<~TGGL)
          toggleShow('show', null, 'desk', 'show_wipearea', null);
        TGGL
        link
      end
    end

    class MultimediaButtons < HtmlGrid::DivComposite
      CSS_CLASS  = 'multimedia-buttons'
      COMPONENTS = {
        [0, 0, 1] => MultimediaButtonsComposite,
      }
    end

    class SlideShowRackComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => component(SerieWidget, :serie_items, 'rack'),
        [0, 1] => MultimediaButtons,
      }
      CSS_ID_MAP = {
        0 => 'show_container',
      }
    end

    class GallerySlideShowRackComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => :close_x,
        [0, 1] => :show,
        [0, 2] => MultimediaButtons,
      }
      CSS_ID_MAP = {
        0 => 'close_x',
        1 => 'show_container',
      }

      def close_x(model)
        link = HtmlGrid::Link.new('close', model, @session, self)
        link.href  = 'javascript:void(0)'
        link.value = 'X'
        link.set_attribute('onclick', <<~TGGL)
          replaceDiv('show_wipearea', 'upper-search-composite');
        TGGL
        link
      end

      def show(model)
        ''
      end
    end
  end
end
