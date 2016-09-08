require 'state/global'
require 'state/predefine'
require 'state/gallery/init'
require 'state/gallery/tooltips'

module DaVaz::State
  module Gallery
    class Global < DaVaz::State::Global
      HOME_STATE = Init
      ZONE       = :gallery
      EVENT_MAP  = {
        :gallery  => Init,
        :tooltips => Tooltips
      }
    end
  end
end
