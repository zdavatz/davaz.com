require 'htmlgrid/divcomposite'
require 'htmlgrid/value'
require 'htmlgrid/divlist'
require 'view/_partial/list'
require 'view/_partial/textblock'
require 'view/template'
require 'util/image_helper'

module DaVaz::View
  module Communication
    class NewsList < HtmlGrid::DivList
      CSS_CLASS  = 'news'
      COMPONENTS = {
        [0, 0] => TextBlock,
      }
    end

    class NewsTitle < HtmlGrid::Div
      CSS_CLASS = 'table-title'

      def init
        super
        span = HtmlGrid::Span.new(model, @session, self)
        span.css_class = 'table-title'
        span.value = @lookandfeel.lookup(:news_from_davaz)
        @value = span
      end
    end

    class NewsComposite < HtmlGrid::DivComposite
      CSS_CLASS  = 'content'
      COMPONENTS = {
        [0, 0] => NewsTitle,
        [1, 0] => NewsList,
      }
      CSS_MAP = {
        [1, 0] => 'news-list',
      }
    end

    class News < CommunicationTemplate
      CONTENT = NewsComposite
    end

    class AdminNewsInnerComposite < HtmlGrid::DivComposite
      CSS_ID     = 'element-container'
      COMPONENTS = {
        [0,0]  =>  component(AdminTextBlockList, :news),
      }
    end

    class AdminNewsComposite < NewsComposite
      COMPONENTS = {
        [0, 0] => NewsTitle,
        [1, 0] => AdminAjaxAddNewElementComposite,
        [2, 0] => AdminNewsInnerComposite,
      }
    end

    class AdminNews < AdminCommunicationTemplate
      CONTENT = AdminNewsComposite
    end
  end
end
