require 'view/publictemplate'
require 'view/textblock'
require 'view/admin/ajax_views'
require 'htmlgrid/divcomposite'
require 'htmlgrid/divlist'
require 'htmlgrid/link'

module DAVAZ
  module View
    module Communication
      class LinksList < HtmlGrid::DivList
        CSS_ID     = 'element_container'
        COMPONENTS = {
          [0, 0] => View::TextBlock,
        }
      end

      class LinksTitle < HtmlGrid::Div
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
          [0, 0] => LinksTitle,
          [1, 0] => LinksList,
        }
      end

      class Links < View::CommunicationPublicTemplate
        CONTENT = View::Communication::LinksComposite
      end

      class AdminLinksInnerComposite < HtmlGrid::DivComposite
        CSS_ID     = 'element_container'
        COMPONENTS = {
          [0, 0] => component(View::AdminTextBlockList, :links),
        }
      end

      class AdminLinksComposite < View::Communication::LinksComposite
        COMPONENTS = {
          [0, 0] => LinksTitle,
          [1, 0] => View::Admin::AjaxAddNewElementComposite,
          [2, 0] => AdminLinksInnerComposite,
        }
      end

      class AdminLinks < View::CommunicationAdminPublicTemplate
        CONTENT = View::Communication::AdminLinksComposite
      end
    end
  end
end
