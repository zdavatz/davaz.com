require 'sbsm/state'
require 'state/predefine'
require 'view/_partial/ajax'

module DaVaz::State
  class Ajax < SBSM::State
    VOLATILE = true
    VIEW     = DaVaz::View::Ajax
  end
end
