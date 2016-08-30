require 'state/predefine'
require 'view/gallery/result'

module DaVaz
  module State
    module Gallery
      class Result < State::Gallery::Global
        VIEW = View::Gallery::Result
      end
    end
  end
end
