require 'state/works/rack'
require 'view/works/paintings'

module DaVaz::State
  module Works
    class Paintings < Rack
      VIEW        = DaVaz::View::Works::Paintings
      ARTGROUP_ID = 'PAI'
    end

    # @api admin
    class AdminPaintings < AdminRack
      VIEW        = DaVaz::View::Works::AdminPaintings
      ARTGROUP_ID = 'PAI'
    end
  end
end
