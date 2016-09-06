require 'htmlgrid/divcomposite'
require 'htmlgrid/divlist'
require 'htmlgrid/div'
require 'view/_partial/textblock'
require 'view/_partial/element'
require 'view/template'

module DaVaz::View
  module Communication
    class OnelinerList < HtmlGrid::DivList
      CSS_ID     = 'element_container'
      COMPONENTS = {
        [0, 0] => OnelinerTextBlock,
      }
    end

    class OnelinerTitle < HtmlGrid::Div
      CSS_CLASS = 'oneliner-title'

      def init
        super
        span = HtmlGrid::Span.new(model, @session)
        span.value = @lookandfeel.lookup(:oneliners_by_davaz)
        @value = span
      end
    end

    class OnelinersComposite < HtmlGrid::DivComposite
      CSS_CLASS  = 'content'
      COMPONENTS = {
        [0, 0] => OnelinerTitle,
        [1, 0] => OnelinerList,
     }
    end

    class Oneliners < CommunicationTemplate
      CONTENT = OnelinersComposite
    end

    # @api admin
    class AdminOnelinerNote < HtmlGrid::Div
      CSS_CLASS = 'oneliner-note'

      def init
        super
        # NOTE for admin user
        @value = <<~EOS.gsub(/\n/, '')
        <h4 style="color:red;">NOTE</h4>
        <ul class="oneliner-admin-note">
          <li>Enter <span style="font-weight:bold">new line</span> in every phrase</li>
          <li>See <a target="_blank" href="https://en.wikipedia.org/wiki/Web_colors#HTML_color_names">this list</a> about color names</li>
          <li>Choose location text from <code>{hisfamily|hisinspiration|hislife|hiswork|index}</code> (index is top page)</li>
          <li>Set status <span style="color:green">1:enabled</span> <span style="color:red">0:disabled</span></li>
        </ul>
        EOS
      end
    end

    # @api admin
    class AdminOnelinersInnerComposite < HtmlGrid::DivComposite
      CSS_ID  = 'element_container'
      COMPONENTS = {
        [1, 0] => AdminOnelinerTextBlockList
      }
    end

    # @api admin
    class AdminOnelinersComposite < OnelinersComposite
      COMPONENTS = {
        [0, 0] => OnelinerTitle,
        [1, 0] => AdminOnelinerNote,
        [2, 0] => AdminAjaxAddNewElementComposite,
        [3, 0] => AdminOnelinersInnerComposite,
      }
    end

    # @api admin
    class AdminOneliners < AdminCommunicationTemplate
      CONTENT = AdminOnelinersComposite
    end
  end
end
