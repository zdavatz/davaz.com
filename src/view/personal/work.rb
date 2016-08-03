require 'htmlgrid/divcomposite'
require 'htmlgrid/div'
require 'htmlgrid/divlist'
require 'htmlgrid/image'
require 'htmlgrid/link'
require 'view/template'
require 'view/_partial/textblock'
require 'view/_partial/oneliner'

module DaVaz::View
  module Personal
    class WorkTitle < HtmlGrid::Div
      CSS_CLASS = 'table-title center'

      def init
        super
        img = HtmlGrid::Image.new(:work_title, model, @session, self)
        @value = img
      end
    end

    class WorkText < HtmlGrid::DivList
      CSS_CLASS  = 'intro-text'
      COMPONENTS = {
        [0, 0] => TextBlock,
      }
    end

    class WorkComposite < HtmlGrid::DivComposite
      CSS_CLASS  = 'content'
      COMPONENTS = {
        [0, 0] => WorkTitle,
        [1, 0] => component(OneLiner, :oneliner),
        [2, 0] => :morphopolis_ticker_link,
        [3, 0] => component(WorkText, :text),
      }

      def morphopolis_ticker_link(model)
        link = HtmlGrid::Link.new(
          :morphopolis_ticker_link, model, @session, self)
        link.href  = 'javascript:void(0)'
        link.value = @lookandfeel.lookup(:morphopolis_ticker_link)
        link.set_attribute('onclick', 'toggleTicker();')
        div = HtmlGrid::Div.new(model, @session, self)
        div.css_id = 'ticker_link'
        div.value  = link
        div
      end
    end

    class Work < PersonalTemplate
      CONTENT = WorkComposite
      TICKER  = 'morphopolis'
    end

    # @api admin
    class AdminWorkTextInnerComposite < HtmlGrid::DivComposite
      CSS_ID     = 'element_container'
      COMPONENTS = {
        [0, 0] => component(AdminTextBlockList, :text),
      }
    end

    # @api admin
    class AdminWorkComposite < WorkComposite
      COMPONENTS = {
        [0, 0] => WorkTitle,
        [1, 0] => component(OneLiner, :oneliner),
        [2, 0] => :morphopolis_ticker_link,
        [3, 0] => AdminAjaxAddNewElementComposite,
        [4, 0] => AdminWorkTextInnerComposite,
      }
    end

    # @api admin
    class AdminWork < AdminPersonalTemplate
      CONTENT = AdminWorkComposite
      TICKER  = 'morphopolis'
    end
  end
end
