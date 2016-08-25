require 'date'
require 'state/_partial/element'
require 'state/communication/global'
require 'view/communication/news'

module DaVaz::State
  module Communication
    class News < Global
      VIEW = DaVaz::View::Communication::News

      def init
        @model = @session.app.load_news
      end
    end

    # @api admin
    class AdminAddNewNwsElement < AdminAddNewElement
      def init
        values = {
          :serie_id => @model.serie_id,
          :title    => @session.lookandfeel.lookup(:click2edit),
          :date     => Date.today.to_s,
          :text     => @session.lookandfeel.lookup(:click2edit_textarea),
        }
        insert_id = @session.app.insert_artobject(values)
        @model = @session.app.load_artobject(insert_id)
      end
    end

    # @api admin
    class AdminNews < News
      VIEW = DaVaz::View::Communication::AdminNews

      def init
        @model = OpenStruct.new
        @model.news = @session.app.load_news
        @model.serie_id = @session.app.load_serie_id('Site News')
      end

      def ajax_add_new_element
        AdminAddNewNwsElement.new(@session, @model)
      end
    end
  end
end
