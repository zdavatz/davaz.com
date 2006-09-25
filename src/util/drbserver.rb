#!/usr/bin/env ruby
# DavazApp -- davaz.com -- 18.07.2005 -- mhuggler@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))

require 'util/validator'
require 'util/session'
require 'sbsm/drbserver'
require 'sbsm/index'
#require 'util/drb'
#require 'util/config'

module DAVAZ
	module Util
		class DRbServer < SBSM::DRbServer
			SESSION = DAVAZ::Util::Session
			VALIDATOR = DAVAZ::Util::Validator
			ENABLE_ADMIN = true
		end
	end
end
