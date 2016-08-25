require 'state/_partial/element'
require 'state/personal/global'
require 'view/personal/work'

module DaVaz::State
  module Personal
    class Work < Global
      VIEW = DaVaz::View::Personal::Work
      DIRECT_EVENT = :work

      def init
        @model = OpenStruct.new
        @model.text     = @session.app.load_hiswork_text
        @model.show     = @session.app.load_tag_artobjects('Morphopolis')
        @model.oneliner = @session.app.load_oneliner('hiswork')
      end
    end

    # @api admin
    class AdminAddNewTxtElement < AdminAddNewElement
      def init
        values = {
          :text => @session.lookandfeel.lookup(:click2edit)
        }
        insert_id = @session.app.insert_artobject(values)
        @model = @session.app.load_artobject(insert_id)
      end
    end

    # @api admin
    class AdminWork < Work
      VIEW = DaVaz::View::Personal::AdminWork

      def ajax_add_new_element
        AdminAddNewTxtElement.new(@session, @model)
      end
    end
  end
end
