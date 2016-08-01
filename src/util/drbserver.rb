# DaVazApp -- davaz.com -- 18.07.2005 -- mhuggler@ywesee.com

require 'util/validator'
require 'util/session'
require 'sbsm/drbserver'

module DaVaz
  module Util
    class DRbServer < SBSM::DRbServer
      SESSION      = DaVaz::Util::Session
      VALIDATOR    = DaVaz::Util::Validator
      ENABLE_ADMIN = true
    end
  end
end
