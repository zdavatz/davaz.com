require 'htmlgrid/divcomposite'
require 'htmlgrid/divlist'
require 'htmlgrid/div'
require 'view/_partial/textblock'
require 'view/_partial/element'
require 'view/template'

module DaVaz::View
  module Gallery
    class TooltipList < HtmlGrid::DivList
      CSS_ID     = 'element_container'
      COMPONENTS = {
        [0, 0] => TooltipTextBlock,
      }
    end

    class TooltipTitle < HtmlGrid::Div
      CSS_CLASS = 'tooltip-title'

      def init
        super
        span = HtmlGrid::Span.new(model, @session)
        span.value = @lookandfeel.lookup(:tooltips_on_davaz)
        @value = span
      end
    end

    class TooltipsComposite < HtmlGrid::DivComposite
      CSS_CLASS  = 'content'
      COMPONENTS = {
        [0, 0] => TooltipTitle,
        [1, 0] => TooltipList,
     }
    end

    class Tooltips < GalleryTemplate
      CONTENT = TooltipsComposite
    end

    # @api admin
    class AdminTooltipNote < HtmlGrid::Div
      CSS_CLASS = 'tooltip-note'

      def init
        super
        # NOTE for admin user
        @value = <<~EOS.gsub(/\n/, '')
        <h4 style="color:red;">NOTE</h4>
        <ul class="tooltip-admin-note">
          <li>In text, matched <span style="font-weight:bold">word</span> will be changed as tooltip</li>
          <li>Artobject which has <span style="color: gray;">URL</span>, can't be assigned as tooltip (it will be external link)</li>
          <li>FROM: source artobject, TO: tooltip artobject</li>
        </ul>
        EOS
      end
    end

    # @api admin
    class AdminTooltipsInnerComposite < HtmlGrid::DivComposite
      CSS_ID  = 'element_container'
      COMPONENTS = {
        [1, 0] => AdminTooltipTextBlockList
      }
    end

    # @api admin
    class AdminTooltipsComposite < TooltipsComposite
      COMPONENTS = {
        [0, 0] => TooltipTitle,
        [1, 0] => AdminTooltipNote,
        [2, 0] => AdminAjaxAddNewElementComposite,
        [3, 0] => AdminTooltipsInnerComposite,
      }
    end

    # @api admin
    class AdminTooltips < AdminGalleryTemplate
      CONTENT = AdminTooltipsComposite
    end
  end
end
