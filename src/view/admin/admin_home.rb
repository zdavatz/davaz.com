#!/usr/bin/env ruby
# View::Admin::AdminHome -- davaz.com -- 27.06.2006 -- mhuggler@ywesee.com

require 'view/publictemplate'

module DAVAZ
	module View
		module Admin
class AdminHomeComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	'successfull_login',
	}
end
class AdminHome < View::PublicTemplate
	CONTENT = AdminHomeComposite
end
		end
	end
end
