require 'htmlgrid/divcomposite'
require 'view/serie_links'
require 'view/show'
require 'view/add_onload'

module DAVAZ
  module View
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

      class Works < HtmlGrid::DivComposite
        include SerieLinks
        CSS_CLASS  = 'content'
        COMPONENTS = {
          [0, 0] => WorksTitle,
          [0, 1] => ShowComposite,
          [0, 2] => :series,
          [0, 3] => AddOnloadShow,
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
end
