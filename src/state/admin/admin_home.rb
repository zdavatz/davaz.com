#!/usr/bin/env ruby
# State::Admin::AdminHome -- davaz.com -- 27.06.2006 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'state/admin/admin'
require 'view/admin/admin_home'

module DAVAZ
	module State
		module Admin
class AdminHome < State::Admin::Global 
	VIEW = View::Admin::AdminHome
end
		end
	end
end
