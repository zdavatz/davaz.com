require 'state/predefine'
require 'state/global'
require 'state/admin/init'

module DaVaz::State
	module Admin
    class Global < DaVaz::State::Global
      HOME_STATE = Init
      ZONE       = :admin
    end
	end
end
