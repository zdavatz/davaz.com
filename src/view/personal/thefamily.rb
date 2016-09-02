require 'view/template'
require 'view/_partial/textblock'
require 'htmlgrid/divcomposite'
require 'htmlgrid/divlist'

module DaVaz::View
  module Personal
    class TheFamilyTitle < HtmlGrid::Div
      CSS_CLASS = 'table-title center'

      def init
        super
        span = HtmlGrid::Span.new(model, @session, self)
        span.value     = @lookandfeel.lookup(:the_family_title)
        span.css_class = 'table-title'
        @value = span
      end
    end

    class TheFamilyBackLink < HtmlGrid::Div
      CSS_CLASS = 'back-link'

      def init
        super
        link = HtmlGrid::Link.new(:family, model, @session, self)
        link.href  = @lookandfeel.event_url(:personal, :family)
        link.value = @lookandfeel.lookup(:back)
        @value = link
      end
    end

    class TheFamilyText < HtmlGrid::DivList
      CSS_CLASS = 'intro-text'
      COMPONENTS = {
        [0, 0] => DaVaz::View::TextBlock
      }

      def init
        super
        self.onload = DaVaz::View::TextBlock.onload_tooltips
      end
    end

    class TheFamilyComposite < HtmlGrid::DivComposite
      CSS_CLASS = 'content'
      COMPONENTS = {
        [0, 0] => TheFamilyTitle,
        [1, 0] => TheFamilyText,
        [2, 0] => TheFamilyBackLink
      }
    end

    class TheFamily < PersonalTemplate
      CONTENT = DaVaz::View::Personal::TheFamilyComposite
    end
  end
end
