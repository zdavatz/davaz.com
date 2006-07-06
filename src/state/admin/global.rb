#!/usr/bin/env ruby
# State::Admin::Global -- davaz.com -- 08.06.2006 -- mhuggler@ywesee.com

require 'state/global'
require 'state/admin/admin_home'
require 'state/admin/login_form'
require 'state/admin/image_browser'

module DAVAZ
	module State
		module Admin
class Global < State::Global
	HOME_STATE = State::Admin::Home
	ZONE = :admin
end
		end
	end
end
