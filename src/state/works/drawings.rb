require 'state/works/rack'
require 'view/works/drawings'

module DaVaz::State
  module Works
    class Drawings < Rack
      VIEW        = DaVaz::View::Works::Drawings
      ARTGROUP_ID = 'DRA'
    end

    # @api ajax
    class AjaxDrawings < Rack
      VIEW        = DaVaz::View::Works::Drawings
      ARTGROUP_ID = 'DRA'
      VOLATILE    = true
    end

    # @api admin
    class AdminDrawings < AdminRack
      VIEW        = DaVaz::View::Works::AdminDrawings
      ARTGROUP_ID = 'DRA'
    end
  end
end
