require 'htmlgrid/divcomposite'
require 'htmlgrid/divlist'
require 'htmlgrid/div'
require 'view/_partial/textblock'
require 'view/template'

module DaVaz::View
  module Public
    class LecturesList < HtmlGrid::DivList
      CSS_CLASS  = 'lectures'
      COMPONENTS = {
        [0, 0] => DaVaz::View::TextBlock
      }

      def init
        super
        self.onload = DaVaz::View::TextBlock.onload_tooltips
      end
    end

    class LecturesTitle < HtmlGrid::Div
      CSS_CLASS = 'table-title'

      def init
        super
        span = HtmlGrid::Span.new(model, @session, self)
        span.css_class = 'table-title'
        span.value     = @lookandfeel.lookup(:lectures)
        @value = span
      end
    end

    class LecturesComposite < HtmlGrid::DivComposite
      CSS_CLASS  = 'content'
      COMPONENTS = {
        [0, 0] => LecturesTitle,
        [1, 0] => LecturesList
      }
    end

    class Lectures < LecturesTemplate
      CONTENT = LecturesComposite
    end

    class AdminLectures < AdminLecturesTemplate
      CONTENT = LecturesComposite
    end
  end
end
