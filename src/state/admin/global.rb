require 'state/predefine'
require 'state/global'
require 'state/personal/init'

module DaVaz::State
	module Admin
    class Global < DaVaz::State::Global
      HOME_STATE = Personal::Init
      ZONE       = :admin
    end
	end
end
