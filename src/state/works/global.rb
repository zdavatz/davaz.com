require 'state/global'
require 'state/predefine'
require 'state/works/init'
require 'state/works/design'
require 'state/works/drawings'
require 'state/works/multiples'
require 'state/works/paintings'
require 'state/works/photos'
require 'state/works/schnitzenthesen'
require 'state/works/movies'
require 'state/works/shorts'

module DaVaz::State
  module Works
    class Global < DaVaz::State::Global
      HOME_STATE = Init
      ZONE       = :works
      EVENT_MAP  = {
        :design          => Design,
        :drawings        => Drawings,
        :multiples       => Multiples,
        :paintings       => Paintings,
        :photos          => Photos,
        :schnitzenthesen => Schnitzenthesen,
        :movies          => Movies,
        :shorts          => Shorts,
      }
    end
  end
end
