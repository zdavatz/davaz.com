require 'htmlgrid/divcomposite'
require 'view/_partial/serie_links'
require 'view/_partial/show'
require 'view/_partial/onload'

module DaVaz::View
  module Works
    class WorksTitle < HtmlGrid::Div
      CSS_CLASS = 'table-title'

      def init
        super
        span = HtmlGrid::Span.new(model, @session, self)
        span.css_class = 'table-title'
        span.value     = @lookandfeel.lookup(@session.event)
        @value = span
      end
    end

    class Init < HtmlGrid::DivComposite
      include SerieLinks

      CSS_CLASS  = 'content'
      COMPONENTS = {
        [0, 0] => WorksTitle,
        [0, 1] => ShowComposite,
        [0, 2] => :series,
        [0, 3] => OnloadShow,
      }
      CSS_ID_MAP = {
        1 => 'show_wipearea',
        2 => 'serie_links',
      }

      def series(model)
        super(model, 'null')
      end
    end
  end
end
