require 'sbsm/state'
require 'view/_partial/redirect'

module DaVaz::State
  class Redirect < SBSM::State
    VIEW = DaVaz::View::Redirect
  end
end
