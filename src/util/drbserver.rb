# DavazApp -- davaz.com -- 18.07.2005 -- mhuggler@ywesee.com

require 'util/validator'
require 'util/session'
require 'sbsm/drbserver'

module DAVAZ
  module Util
    class DRbServer < SBSM::DRbServer
      SESSION      = DAVAZ::Util::Session
      VALIDATOR    = DAVAZ::Util::Validator
      ENABLE_ADMIN = true
    end
  end
end
