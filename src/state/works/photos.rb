require 'state/works/rack'
require 'view/works/photos'

module DaVaz::State
  module Works
    class Photos < Rack
      VIEW        = DaVaz::View::Works::Photos
      ARTGROUP_ID = 'PHO'
    end

    class AdminPhotos < AdminRack
      VIEW        = DaVaz::View::Works::AdminPhotos
      ARTGROUP_ID = 'PHO'
    end
  end
end
