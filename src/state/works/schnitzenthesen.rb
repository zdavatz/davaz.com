require 'state/works/rack'
require 'view/works/schnitzenthesen'

module DaVaz::State
  module Works
    class Schnitzenthesen < Rack
      VIEW        = DaVaz::View::Works::Schnitzenthesen
      ARTGROUP_ID = 'SCH'
    end

    # @api admin
    class AdminSchnitzenthesen < AdminRack
      VIEW        = DaVaz::View::Works::AdminSchnitzenthesen
      ARTGROUP_ID = 'SCH'
    end
  end
end
