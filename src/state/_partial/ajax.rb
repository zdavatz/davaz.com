require 'state/global'
require 'view/_partial/ajax'

module DaVaz::State
  class Ajax < Global
    VOLATILE = true
    VIEW     = DaVaz::View::Ajax
  end
end
