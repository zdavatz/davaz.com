#!/usr/bin/env ruby
# View::Works::Schnitzenthesen -- davaz.com -- 28.09.2005 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/divcomposite'

module DAVAZ
	module View
		module Works
class SchnitzenthesenComposite < View::Works::Works; end
class Schnitzenthesen < View::SchnitzenthesenPublicTemplate
	CONTENT = View::Works::SchnitzenthesenComposite 
end
		end
	end
end
