require 'date'
require 'state/_partial/element'
require 'state/communication/global'
require 'view/communication/oneliners'

module DaVaz::State
  module Communication
    class Oneliners < Global
      VIEW = DaVaz::View::Communication::Oneliners

      def init
        @model = @session.app.load_oneliners
      end
    end

    # @api admin
    class AdminAddNewOnelinerElement < AdminAddNewElement
      VIEW     = DaVaz::View::AdminOnelinerLiveEditor
      VOLATILE = true

      def init
        values = {
          :text     => @session.lookandfeel.lookup(:click2edit_textarea),
          :location => 'hislife',
          :color    => 'black',
          :size     => 18,
          :active   => 1
        }
        insert_id = @session.app.insert_oneliner(values)
        @model = @session.app.load_oneliner(insert_id)
      end
    end

    # @api admin
    class AdminOneliners < Oneliners
      VIEW = DaVaz::View::Communication::AdminOneliners

      def ajax_add_new_element
        AdminAddNewOnelinerElement.new(@session, @model)
      end
    end
  end
end
