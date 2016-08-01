require 'state/works/rack'
require 'view/works/design'

module DaVaz::State
  module Works
    class Design < Rack
      VIEW        = DaVaz::View::Works::Design
      ARTGROUP_ID = 'DES'
    end

    class AdminDesign < AdminRack
      VIEW        = DaVaz::View::Works::AdminDesign
      ARTGROUP_ID = 'DES'
    end
  end
end
