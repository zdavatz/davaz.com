require 'htmlgrid/divcomposite'
require 'htmlgrid/divlist'
require 'htmlgrid/link'
require 'view/template'
require 'view/_partial/textblock'
require 'view/admin/ajax'

module DaVaz::View
  module Communication
    class LinkList < HtmlGrid::DivList
      CSS_ID     = 'element_container'
      COMPONENTS = {
        [0, 0] => TextBlock,
      }
    end

    class LinkTitle < HtmlGrid::Div
      CSS_CLASS = 'table-title'

      def init
        super
        span = HtmlGrid::Span.new(model, @session)
        span.value     = @lookandfeel.lookup(:links_from_davaz)
        span.css_class = 'table-title'
        @value = span
      end
    end

    class LinksComposite < HtmlGrid::DivComposite
      CSS_CLASS  = 'content'
      COMPONENTS = {
        [0, 0] => LinkTitle,
        [1, 0] => LinkList,
      }
    end

    class Links < CommunicationTemplate
      CONTENT = LinksComposite
    end

    # @api admin
    class AdminLinksInnerComposite < HtmlGrid::DivComposite
      CSS_ID     = 'element_container'
      COMPONENTS = {
        [0, 0] => component(AdminTextBlockList, :links)
      }
    end

    # @api admin
    class AdminLinksComposite < LinksComposite
      COMPONENTS = {
        [0, 0] => LinkTitle,
        [1, 0] => Admin::AjaxAddNewElementComposite,
        [2, 0] => AdminLinksInnerComposite,
      }
    end

    # @api admin
    class AdminLinks < AdminCommunicationTemplate
      CONTENT = AdminLinksComposite
    end
  end
end
