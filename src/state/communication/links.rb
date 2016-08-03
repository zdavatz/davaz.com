require 'date'
require 'state/_partial/element'
require 'state/communication/global'
require 'view/communication/links'

module DaVaz::State
  module Communication
    class Links < Global
      VIEW = DaVaz::View::Communication::Links

      def init
        @model = @session.app.load_links
      end
    end

    # @api admin
    class AdminAjaxAddNewLinkElement < AdminAjaxAddNewElement
      def init
        values = {
          :serie_id => @model.serie_id,
          :url      => @session.lookandfeel.lookup(:click2edit),
          :date     => Date.today.to_s,
          :text     => @session.lookandfeel.lookup(:click2edit_textarea),
        }
        insert_id = @session.app.insert_artobject(values)
        @model = @session.app.load_artobject(insert_id)
      end
    end

    # @api admin
    class AdminLinks < Global
      VIEW = DaVaz::View::Communication::AdminLinks

      def init
        @model = OpenStruct.new
        @model.links = @session.app.load_links
        @model.serie_id = @session.app.load_serie_id('Site Links')
      end

      def ajax_add_new_element
        AdminAjaxAddNewLinkElement.new(@session, @model)
      end
    end
  end
end
