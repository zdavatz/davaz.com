require 'date'
require 'state/_partial/element'
require 'state/gallery/global'
require 'view/_partial/textblock'
require 'view/gallery/tooltips'

module DaVaz::State
  module Gallery
    class Tooltips < Global
      VIEW = DaVaz::View::Gallery::Tooltips

      def init
        @model = @session.app.load_tooltip_links
      end
    end

    # @api admin
    class AdminAddNewTooltipElement < AdminAddNewElement
      #VIEW     = DaVaz::View::AdminTooltipLiveEditor
      VIEW     = DaVaz::View::AdminTooltipTextBlock
      VOLATILE = true

      def init
        values = {
          # dummy artobejct_id, linked_artobject_id
          :artobject_id        => '1',
          :word                => 'tooltip',
          :linked_artobject_id => '1'
        }
        insert_id = @session.app.insert_link(values)
        @model = @session.app.load_tooltip_link(insert_id)
      end
    end

    # @api admin
    class AdminTooltips < Tooltips
      VIEW = DaVaz::View::Gallery::AdminTooltips

      def ajax_add_new_element
        AdminAddNewTooltipElement.new(@session, @model)
      end
    end
  end
end
