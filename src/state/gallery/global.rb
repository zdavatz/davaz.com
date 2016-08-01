require 'state/global'
require 'state/predefine'
require 'state/gallery/init'

module DaVaz::State
  module Gallery
    class Global < DaVaz::State::Global
      HOME_STATE = Init
      ZONE       = :gallery
      EVENT_MAP  = {
        :gallery => Init
      }
    end
  end
end
