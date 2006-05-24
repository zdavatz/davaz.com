#!/usr/bin/env ruby
# View::Works::Carpets -- davaz.com -- 28.09.2005 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/works/works'

module DAVAZ
	module View
		module Works
class CarpetsComposite < View::Works::Works; end
class Carpets < View::CarpetsPublicTemplate
	CONTENT = View::Works::CarpetsComposite 
end
		end
	end
end
