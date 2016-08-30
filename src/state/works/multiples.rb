require 'sbsm/state'
require 'state/works/rack'
require 'view/works/multiples'

module DaVaz::State
  module Works
    class AjaxMultiples < SBSM::State
      VIEW     = DaVaz::View::Works::JavaApplet
      VOLATILE = true

      def init
        @model = @session.user_input(:artobject_id)
      end
    end

    class Multiples < Rack
      VIEW = DaVaz::View::Works::Multiples

      def init
        @model = OpenStruct.new
        multiples = @session.app.load_multiples
        @model.default_artobject_id = multiples.first.artobject_id
        @model.multiples = @session.app.load_multiples()
      end
    end
  end
end
