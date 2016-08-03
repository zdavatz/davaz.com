require 'htmlgrid/divcomposite'
require 'htmlgrid/spanlist'
require 'htmlgrid/div'
require 'htmlgrid/inputtext'
require 'htmlgrid/form'
require 'htmlgrid/button'
require 'htmlgrid/image'
require 'view/_partial/onload'
require 'view/_partial/serie_widget'
require 'view/_partial/serie_links'
require 'view/_partial/oneliner'
require 'view/template'

module DaVaz::View
  module Gallery

    class SearchTitle < HtmlGrid::Div
      CSS_CLASS = 'gallery-table-title center'

      def init
        super
        @value = HtmlGrid::Image.new(
          :gallery_search_title, model, @session, self)
      end
    end

    class SeriesTitle < HtmlGrid::Div
      CSS_CLASS = 'gallery-table-title center'

      def init
        super
        @value = HtmlGrid::Image.new(
          :series_title, model, @session, self)
      end
    end

    class InputBar < HtmlGrid::InputText
      def init
        super
        @attributes.update('id' =>  'searchbar')
        self.set_attribute('onsubmit', <<~EOS.gsub(/\n/, ''))
          if (#{@name}.value!='#{@lookandfeel.lookup(@name)}') {
            var href = '#{@lookandfeel.event_url( \
              :gallery, :search, [@name, ''])}'"
              + encodeURIComponent(#{@name}.value.replace(/\\//, '%2F'));
            document.location.href = href;
          };
          return false;
        EOS
      end
    end

    class SearchBar < HtmlGrid::Form
      CSS_CLASS  = 'center'
      COMPONENTS = {
        [0,0] => :search_query,
        [0,1] => :submit,
        [1,1] => :search_reset,
      }
      COLSPAN_MAP = {
        [0,0] => 2,
      }
      SYMBOL_MAP = {
        :search_query => InputBar,
      }
      EVENT = :search
      FORM_METHOD = 'POST'

      def init
        self.onload = "document.getElementById('searchbar').focus();"
        super
      end

      def search_reset(model, session)
        button = HtmlGrid::Button.new(:search_reset, model, session, self)
        button.set_attribute('type', 'reset')
        button
      end
    end

    class UpperGalleryComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => SearchTitle,
        [0, 1] => GalleryNavigation,
        [0, 2] => SearchBar,
        [0, 3] => component(OneLiner, :oneliner),
        [0, 4] => SeriesTitle,
      }
      CSS_ID_MAP = {
        0 => 'search_title',
        1 => 'gallery_navigation',
        2 => 'search_bar',
        3 => 'search_oneliner',
      }
    end

    class GalleryComposite < HtmlGrid::DivComposite
      include SerieLinks

      CSS_ID     = 'inner_content'
      COMPONENTS = {
        [0, 0] => UpperGalleryComposite,
        [0, 1] => :show,
        [0, 2] => :series,
        [0, 3] => OnloadShow,
      }
      CSS_STYLE_MAP = {
        1 => 'display:none;',
      }
      CSS_ID_MAP = {
        0 => 'show_container',
        1 => 'show_wipearea',
        2 => 'serie_links',
      }

      def show(model)
        GalleryShowComposite.new([], @session, self)
      end

      def series(model)
        super(model, 'show_container')
      end
    end

    class Gallery < GalleryTemplate
      CONTENT = GalleryComposite
    end

    class AdminGallery < AdminGalleryTemplate
      CONTENT = GalleryComposite
    end
  end
end
