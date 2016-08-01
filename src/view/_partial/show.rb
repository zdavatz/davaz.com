require 'htmlgrid/dojotoolkit'
require 'htmlgrid/divcomposite'
require 'view/_partial/serie_widget'
require 'util/image_helper'

module DaVaz
  module View
    class MultimediaButtonsComposite < HtmlGrid::DivComposite
      CSS_CLASS  = 'multimedia-control'
      COMPONENTS = {
        [0, 0]    => :rack,
        [0, 0, 1] => :slide,
        [0, 0, 2] => :desk,
      }

      def rack(model)
        img = HtmlGrid::Image.new(:rack, model, @session, self)
        link = HtmlGrid::Link.new(:rack, model, @session, self)
        link.value = img
        link.href  = 'javascript:void(0)'
        link.set_attribute('onclick', <<~EOS)
          toggleShow('show', null, 'rack', 'show_wipearea', null);
        EOS
        link
      end

      def slide(model)
        img = HtmlGrid::Image.new(:slide, model, @session, self)
        link = HtmlGrid::Link.new(:slide, model, @session, self)
        link.value = img
        link.href  = 'javascript:void(0)'
        link.set_attribute('onclick', <<~EOS)
          toggleShow('show', null, 'slide', 'show_wipearea', null);
        EOS
        link
      end

      def desk(model)
        img = HtmlGrid::Image.new(:desk, model, @session, self)
        link = HtmlGrid::Link.new(:desk, model, @session, self)
        link.value = img
        link.href  = 'javascript:void(0)'
        link.set_attribute('onclick', <<~EOS)
          toggleShow('show', null, 'desk', 'show_wipearea', null);
        EOS
        link
      end
    end

    class MultimediaButtons < HtmlGrid::DivComposite
      CSS_CLASS  = 'multimedia-buttons'
      COMPONENTS = {
        [0, 0, 1] => MultimediaButtonsComposite,
      }
    end

    class ShowComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => component(SerieWidget, :serie_items, 'rack'),
        [0, 1] => MultimediaButtons,
      }
      CSS_ID_MAP = {
        0 => 'show_container',
      }
    end

    class GalleryShowComposite < HtmlGrid::DivComposite
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
        link.set_attribute('onclick', <<~EOS)
          replaceDiv('show_wipearea', 'show_container');
        EOS
        link
      end

      def show(model)
        ''
      end
    end
  end
end
