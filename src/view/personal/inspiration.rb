require 'htmlgrid/divcomposite'
require 'htmlgrid/divlist'
require 'htmlgrid/image'
require 'htmlgrid/link'
require 'view/template'
require 'view/_partial/textblock'
require 'view/_partial/oneliner'
require 'view/personal/life'

module DaVaz::View
  module Personal
    class InspirationTitle < HtmlGrid::Div
      CSS_CLASS = 'table-title center'

      def init
        super
        img = HtmlGrid::Image.new(:inspiration_title, model, @session, self)
        @value = img
      end
    end

    class InspirationText < HtmlGrid::DivList
      CSS_CLASS  = 'intro-text'
      COMPONENTS = {
        [0, 0] => TextBlock,
      }

      def init
        super
        self.onload = DaVaz::View::TextBlock.onload_tooltips
      end
    end

    class InspirationComposite < HtmlGrid::DivComposite
      CSS_ID = 'inner_content'
      COMPONENTS = {
        [0, 0] => InspirationTitle,
        [1, 0] => component(Oneliner, :oneliner),
        [2, 0] => :india_ticker_link,
        [3, 0] => component(InspirationText, :text),
      }

      def india_ticker_link(model)
        link = HtmlGrid::Link.new(:india_ticker_link, model, @session, self)
        link.href  = 'javascript:void(0);'
        link.value = @lookandfeel.lookup(:india_ticker_link)
        link.set_attribute('onclick', 'return toggleTicker();')
        div = HtmlGrid::Div.new(model, @session, self)
        div.css_id = 'ticker_link'
        div.value  = link
        div
      end
    end

    class Inspiration < PersonalTemplate
      CONTENT = InspirationComposite
      TICKER  = 'A passage through India'
    end
  end
end
