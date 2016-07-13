require 'state/global_predefine'
require 'view/gallery/result'

module DAVAZ
  module State
    module Gallery
      class Result < State::Gallery::Global
        VIEW = View::Gallery::Result
      end
    end
  end
end
