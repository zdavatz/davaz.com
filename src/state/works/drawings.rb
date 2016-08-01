require 'state/global_predefine'
require 'state/works/rack_state'
require 'view/works/drawings'

module DAVAZ
  module State
    module Works
      class Drawings < State::Works::RackState
        VIEW        = View::Works::Drawings
        ARTGROUP_ID = 'DRA'
      end

      # @api ajax
      class AjaxDrawings < State::Works::RackState
        VIEW        = View::Works::Drawings
        ARTGROUP_ID = 'DRA'
        VOLATILE    = true
      end

      # @api admin
      class AdminDrawings < State::Works::AdminRackState
        VIEW        = View::Works::AdminDrawings
        ARTGROUP_ID = 'DRA'
      end
    end
  end
end
