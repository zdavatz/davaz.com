require 'view/template'
require 'htmlgrid/divcomposite'
require 'htmlgrid/divlist'

module DaVaz::View
  module Public
    class ExhibitionsList < HtmlGrid::DivList
      CSS_CLASS  = 'exhibitions'
      COMPONENTS = {
        [0, 0] => DaVaz::View::TextBlock,
      }
    end

    class ExhibitionsTitle < HtmlGrid::Div
      CSS_CLASS = 'table-title'

      def init
        super
        span = HtmlGrid::Span.new(model, @session, self)
        span.css_class = 'table-title'
        span.value = @lookandfeel.lookup(:exhibitions)
        @value = span
      end
    end

    class ExhibitionsComposite < HtmlGrid::DivComposite
      CSS_CLASS  = 'content'
      COMPONENTS = {
        [0, 0] => ExhibitionsTitle,
        [1, 0] => ExhibitionsList,
      }
    end

    class Exhibitions < ExhibitionsTemplate
      CONTENT = ExhibitionsComposite
    end

    class AdminExhibitions < AdminExhibitionsTemplate
      CONTENT = ExhibitionsComposite
    end
  end
end
