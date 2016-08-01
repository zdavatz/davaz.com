require 'state/personal/global'
require 'view/personal/inspiration'

module DaVaz::State
  module Personal
    class Inspiration < Global
      VIEW = DaVaz::View::Personal::Inspiration

      def init
        @model = OpenStruct.new
        @model.text = @session.app.load_hisinspiration_text
        @model.oneliner = @session.app.load_oneliner('hisinspiration')
      end
    end
  end
end
