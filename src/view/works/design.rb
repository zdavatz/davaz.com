#!/usr/bin/env ruby
# View::Works::Design -- davaz.com -- 05.05.2006 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/works/works'

module DAVAZ
	module View
		module Works
class DesignComposite < View::Works::Works; end
class Design < View::DesignPublicTemplate
	CONTENT = View::Works::DesignComposite 
end
		end
	end
end
