require 'htmlgrid/divcomposite'
require 'view/_partial/textblock'
require 'view/_partial/serie_widget'
require 'view/template'

module DaVaz::View
  module Personal
    class FamilyTitle < HtmlGrid::Div
      CSS_CLASS = 'table-title center'

      def init
        super
        img = HtmlGrid::Image.new(:family_title, model, @session, self)
        @value = img
      end
    end

    class FamilyOrigin < HtmlGrid::Div
      css_class = 'family-origin'

      def init
        super
        txt = @lookandfeel.lookup(:family_of_origin)
        @value = txt
      end
    end

    class FamilyText < HtmlGrid::DivList
      CSS_CLASS  = 'intro-text'
      COMPONENTS = {
        [0, 0] => DaVaz::View::TextBlock
      }
    end

    class FamilyForwardLink < HtmlGrid::Div
      CSS_CLASS = 'forward-link'

      def init
        super
        link = HtmlGrid::Link.new(:the_family, model, @session, self)
        link.href = @lookandfeel.event_url(:personal, :the_family)
        link.value = @lookandfeel.lookup(:next)
        @value = link
      end
    end

    class FamilyInfoComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => FamilyOrigin,
        [0, 1] => component(DaVaz::View::SerieWidget, :show_items, 'slide'),
        [0, 2] => component(FamilyText, :family_text),
        [0, 3] => FamilyForwardLink
      }
      CSS_MAP = {
        0 => 'family-origin',
        1 => 'slide',
        2 => 'family-intro',
        3 => 'family-forward-link',
      }
    end

    class FamilyComposite < HtmlGrid::DivComposite
      CSS_CLASS  = 'content'
      COMPONENTS = {
        [0, 0] => FamilyTitle,
        [1, 0] => FamilyInfoComposite
      }
    end

    class Family < PersonalTemplate
      CONTENT = FamilyComposite
    end

    class AdminFamilyComposite < FamilyComposite
      COMPONENTS = {
        [0, 0] => FamilyTitle,
        [1, 0] => FamilyInfoComposite
      }
    end

    class AdminFamily < Family
      CONTENT = AdminFamilyComposite
    end
  end
end
